#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"
require "open3"
require "fileutils"
require "thor"

begin; require "parallel"; rescue LoadError; end
begin; require "concurrent-ruby"; rescue LoadError; end

module Analysis
  DEFAULT_PROMPT = "Find potential bugs and suggest improvements"

  # -------- Small utility helpers ----------
  module Util
    module_function

    def slugify(str, max: 48)
      s = str.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-+|-+$/, "")
      s[0, max].sub(/-+\z/, "")
    end

    def read_limited(path, limit = 200_000)
      File.open(path, "rb") { |f| f.read(limit) }
    end

    def uniq_exist_paths(paths)
      paths.uniq.select { |p| File.file?(p) }
    end

    # Greedy-but-safe path finder for “app/models/foo.rb”, “spec/...”, etc.
    def extract_paths(text)
      candidates = text.scan(%r{(?:^|\s)([A-Za-z0-9._/\-]+(?:\.[A-Za-z0-9]+))}).flatten
      # Keep repo-like paths
      candidates.select { |p| p.include?("/") || p.start_with?("./") || p.start_with?("../") }
    end

    def lock_append(path, line)
      File.open(path, "a") do |f|
        f.flock(File::LOCK_EX)
        f.puts(line)
      ensure
        f.flock(File::LOCK_UN) rescue nil
      end
    end
  end

  Job = Struct.new(:task_name, :file, :base, :out_dir, :log_path, :prompt, :stdin_data, keyword_init: true)

  # -------- Input adapters ----------
  class YAMLConfig
    def initialize(cfg_hash, defaults)
      @cfg = cfg_hash || {}
      @defaults = defaults
    end

    def tasks
      ts = Array(@cfg["tasks"])
      return [] if ts.empty?
      ts.each_with_index.map do |t, idx|
        {
          name: (t["name"] || "task-#{idx + 1}"),
          glob: t.fetch("in"),
          out_dir: (t["out"].to_s.empty? ? File.join(@defaults[:out], (t["name"] || "task-#{idx + 1}")) : t["out"]),
          log_name: (t["log"].to_s.empty? ? @defaults[:log] : t["log"]),
          prompt: (t["prompt"].to_s.empty? ? @defaults[:prompt] : t["prompt"])
        }
      end
    end

    def jobs
      tasks.flat_map do |t|
        files = Dir.glob(t[:glob], File::FNM_EXTGLOB | File::FNM_CASEFOLD)
        next [] if files.empty?
        log_path = File.join(t[:out_dir], t[:log_name])
        files.map do |f|
          Job.new(
            task_name: t[:name],
            file: f,
            base: File.basename(f),
            out_dir: t[:out_dir],
            log_path: log_path,
            prompt: t[:prompt],
            stdin_data: nil # read from file
          )
        end
      end
    end
  end

  class JSONTasks
    # Accepts one file that is either an object or an array of objects.
    def initialize(json_hash_or_array, defaults)
      @list = json_hash_or_array.is_a?(Array) ? json_hash_or_array : [json_hash_or_array]
      @defaults = defaults
    end

    def jobs
      @list.flat_map { |obj| jobs_for(obj) }
    end

    private

    def jobs_for(obj)
      task_name = obj["task"] || obj["name"] || obj["id"] || "task"
      project   = obj["project"] || task_name
      subtasks  = Array(obj["subtasks"])
      refs      = Array(obj["must_reference"])

      out_dir   = File.join(@defaults[:out], Util.slugify(project))
      log_path  = File.join(out_dir, "progress.log")

      reference_blobs = refs.filter_map do |r|
        next unless File.file?(r)
        "=== REFERENCE: #{r} ===\n" + Analysis::Util.read_limited(r)
      rescue => e
        "=== REFERENCE: #{r} (read error: #{e.message}) ==="
      end
      refs_section = reference_blobs.join("\n\n")

      subtasks.flat_map.with_index do |st, i|
        st_slug = Util.slugify(st, max: 36)
        paths = Analysis::Util.extract_paths(st)
        files = Analysis::Util.uniq_exist_paths(paths)

        if files.empty?
          # Synthetic job: no concrete file—send the subtask + refs as stdin
          synth_name = "#{task_name}-#{i + 1}"
          body = +"=== TASK ===\n#{st}\n\n"
          body << "#{refs_section}\n" unless refs_section.empty?

          [
            Job.new(
              task_name: synth_name,
              file: nil,
              base: "subtask-#{st_slug}.txt",
              out_dir: out_dir,
              log_path: log_path,
              prompt: "#{@defaults[:prompt]}\n\nEvaluate the TASK below and produce clear, actionable steps.\nIf code changes are implied, propose diffs.\n",
              stdin_data: body
            )
          ]
        else
          files.map do |f|
            base = File.basename(f)
            body = +"=== TASK ===\n#{st}\n\n"
            body << "#{refs_section}\n\n" unless refs_section.empty?
            body << "=== FILE: #{f} ===\n"
            body << Analysis::Util.read_limited(f)

            Job.new(
              task_name: "#{task_name}-#{i + 1}",
              file: f,
              base: "#{base}__#{st_slug}",
              out_dir: out_dir,
              log_path: log_path,
              prompt: "#{@defaults[:prompt]}\n\nApply the TASK to the provided FILE. Prefer precise suggestions or diffs.",
              stdin_data: body
            )
          end
        end
      end
    end
  end

  # -------- Runner (Parallel / concurrent-ruby / sequential) ----------
  class Runner
    def initialize(max_threads)
      @max_threads = [max_threads.to_i, 1].max
    end

    def run(jobs, &block)
      if defined?(Parallel)
        Parallel.each(jobs, in_threads: @max_threads, &block)
      elsif defined?(Concurrent)
        pool = Concurrent::FixedThreadPool.new(@max_threads)
        jobs.each { |j| pool.post { block.call(j) } }
        pool.shutdown; pool.wait_for_termination
      else
        jobs.each { |j| block.call(j) }
      end
    end
  end
end

class Analyzer < Thor
  default_command :execute

  desc "execute", "Analyze files/tasks from YAML configs and/or JSON task files"
  option :config, type: :array,  desc: "One or more YAML config files (tasks[].in, prompt, out, log)"
  option :json,   type: :array,  desc: "One or more JSON task files (Taskwarrior-style records)"
  option :in,     type: :string, desc: "Fallback glob when no --config/--json provided"
  option :out,    type: :string, default: "reports", desc: "Base output directory"
  option :jobs,   type: :numeric, default: 10, desc: "Max concurrent jobs"
  option :prompt, type: :string, default: Analysis::DEFAULT_PROMPT, desc: "Default/global prompt"
  option :dry,    type: :boolean, default: false, desc: "Dry run (do not call gemini)"
  def execute
    defaults = { out: options[:out], prompt: options[:prompt], log: "progress.log" }
    jobs = []

    # YAML sources
    Array(options[:config]).each do |path|
      cfg = safe_load_yaml(path)
      jobs.concat Analysis::YAMLConfig.new(cfg, defaults).jobs
    end

    # JSON sources
    Array(options[:json]).each do |path|
      obj = safe_load_json(path)
      jobs.concat Analysis::JSONTasks.new(obj, defaults).jobs
    end

    # Single CLI-only task (kept for convenience)
    if jobs.empty?
      glob = options[:in]
      abort "Provide --config/--json or --in GLOB" unless glob
      cfg = { "tasks" => [{ "name" => "default", "in" => glob }] }
      jobs.concat Analysis::YAMLConfig.new(cfg, defaults).jobs
    end

    abort "No files or subtasks produced any work." if jobs.empty?

    # Prepare output dirs & logs
    jobs.map(&:out_dir).uniq.each { |d| FileUtils.mkdir_p(d) }
    jobs.map(&:log_path).uniq.each  { |l| FileUtils.touch(l) }

    runner = Analysis::Runner.new(options[:jobs])
    runner.run(jobs) { |job| analyze_one(job, dry: options[:dry]) }

    puts "All analyses complete."
  end

  desc "schema", "Print an example YAML config"
  def schema
    example = {
      "jobs" => 10,
      "out"  => "reports",
      "log"  => "progress.log",
      "prompt" => Analysis::DEFAULT_PROMPT,
      "tasks" => [
        { "name" => "py-bugs", "in" => "src/**/*.py", "prompt" => Analysis::DEFAULT_PROMPT, "out" => "reports/py" },
        { "name" => "js-refactor", "in" => "web/**/*.js", "prompt" => "Suggest refactors", "out" => "reports/js" }
      ]
    }
    puts example.to_yaml
  end

  desc "schema_json", "Print an example JSON task (array form also supported)"
  def schema_json
    example = {
      "id" => "1",
      "task" => "Apply TenantScoped concern to core models",
      "entry" => "2025-10-17",
      "modified" => "2025-10-17",
      "priority" => "H",
      "project" => "mangroves-multi-tenant",
      "status" => "completed",
      "uuid" => "a1b2c3d4-e5f6-4789-a0b1-c2d3e4f5g6h7",
      "urgency" => "10",
      "subtasks" => [
        "Open app/models/workspace.rb, add 'include TenantScoped' after class declaration, and verify 'belongs_to :account' association exists",
        "Open app/models/team.rb, add 'include TenantScoped', ensure account_id is synced from workspace, and keep account/workspace validation in place",
        "Run 'bundle exec rspec spec/models/workspace_spec.rb spec/models/team_spec.rb' to verify no errors introduced"
      ],
      "must_reference" => [
        "mangroves/docs/rails_conventions.md"
      ]
    }
    puts JSON.pretty_generate(example)
  end

  private

  def analyze_one(job, dry:)
    out_file = File.join(job.out_dir, "#{job.base}.analysis")
    puts "Analyzing #{job.file || job.base} (task: #{job.task_name})..."

    if dry
      File.write(out_file, "(dry run) #{job.base} [#{job.task_name}]")
      Analysis::Util.lock_append(job.log_path, "Completed analysis for #{job.base} [#{job.task_name}] (dry)")
      return
    end

    stdin_data =
      if job.stdin_data
        job.stdin_data
      elsif job.file
        File.binread(job.file)
      else
        "" # should not happen, but keep safe
      end

    stdout, stderr, status =
      Open3.capture3("gemini", "-p", job.prompt, "--output-format", "json", stdin_data: stdin_data)

    unless status.success?
      warn "ERROR: gemini failed for #{job.file || job.base}: #{stderr.strip}"
      File.write(File.join(job.out_dir, "#{job.base}.error.txt"), "STDERR:\n#{stderr}\n\nSTDOUT:\n#{stdout}")
      return
    end

    response =
      begin
        obj = JSON.parse(stdout)
        obj["response"] || obj.dig("data", "response") || stdout
      rescue JSON::ParserError
        warn "WARN: JSON parse failed for #{job.file || job.base}, writing raw response"
        stdout
      end

    File.write(out_file, response.to_s)
    Analysis::Util.lock_append(job.log_path, "Completed analysis for #{job.base} [#{job.task_name}]")
  end

  def safe_load_yaml(path)
    YAML.safe_load(File.read(path), permitted_classes: [], aliases: true) || {}
  rescue Psych::SyntaxError => e
    abort "Invalid YAML in #{path}: #{e.message}"
  end

  def safe_load_json(path)
    JSON.parse(File.read(path))
  rescue JSON::ParserError => e
    abort "Invalid JSON in #{path}: #{e.message}"
  end
end

Analyzer.start(ARGV)

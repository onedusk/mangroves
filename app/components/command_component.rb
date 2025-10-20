# frozen_string_literal: true

class CommandComponent < Phlex::HTML
  def initialize(commands)
    @commands = commands
  end

  def template
    div(data: {controller: "command"}) do
      input(
        type: "text",
        data: {action: "input->command#filter"},
        class: "w-full px-4 py-2 border rounded-md",
        placeholder: "Search commands..."
      )
      div(data: {command_target: "results"}, class: "mt-2") do
        @commands.each do |command|
          a(href: command[:href], class: "block px-4 py-2 text-gray-700 hover:bg-gray-100") { command[:name] }
        end
      end
    end
  end
end

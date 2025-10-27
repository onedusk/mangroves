# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"

  SimpleCov.start "rails" do
    add_filter "/bin/"
    add_filter "/db/"
    add_filter "/spec/"
    add_filter "/config/"
    add_filter "/vendor/"
    add_filter "/.bundle/"

    add_group "Models", "app/models"
    add_group "Controllers", "app/controllers"
    add_group "Components", "app/components"
    add_group "Services", "app/services"
    add_group "Policies", "app/policies"
    add_group "Helpers", "app/helpers"
    add_group "Mailers", "app/mailers"
    add_group "Jobs", "app/jobs"
    add_group "Channels", "app/channels"

    minimum_coverage 90
    minimum_coverage_by_file 80

    # Track coverage over time
    track_files "{app,lib}/**/*.rb"
  end
end

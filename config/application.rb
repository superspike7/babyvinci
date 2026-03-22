require_relative "boot"

require "rails/all"

def detected_app_time_zone
  configured = ENV["APP_TIME_ZONE"].presence
  return configured if configured

  zoneinfo_path = File.realpath("/etc/localtime") rescue nil
  zone_name = zoneinfo_path&.split("zoneinfo/")&.last

  ActiveSupport::TimeZone[zone_name]&.name || "UTC"
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Vinci
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = detected_app_time_zone
    # config.eager_load_paths << Rails.root.join("extras")
  end
end

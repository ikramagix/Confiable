require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Confiable
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #

    config.time_zone = "Paris"
    # config.eager_load_paths << Rails.root.join("extras")

    # i18n locale configuration
    # Set the default locale to French
    config.i18n.default_locale = :fr

    # Ensure all available locales are loaded
    config.i18n.available_locales = [ :en, :fr ]

    # Fallback to English if a translation is missing
    config.i18n.fallbacks = [ :en ]
  end
end

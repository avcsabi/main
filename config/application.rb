require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyYellowBook
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    #config.eager_load_paths += Dir["#{config.root}/lib/**/"]
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('lib/companies_house')
    # Dir["#{config.root}/lib/**/"]
    config.x.companies_house = config_for(:companies_house).symbolize_keys

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
  if Rails.configuration.respond_to?(:sass)
    Rails.configuration.sass.tap do |config|
      config.preferred_syntax = :sass
    end
  end
end

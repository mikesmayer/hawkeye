require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rack/cors'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module RailsBootstrap
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.middleware.use Rack::Cors do
      allow do
        origins 'http://www.pitza42.com'
        resource '/meals/*', :headers => :any, :methods => [:post, :get]
      end
    end


    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)

      #separate yml load for prod env
      prod_env_file = File.join('/home/tylersam/webapps/hawkeye/hawk', 'config', 'local_env.yml')
      YAML.load(File.open(prod_env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(prod_env_file)

    end
 
    #config.time_zone = "Central Time (US & Canada)"
    #config.active_record.default_timezone = "Central Time (US & Canada)"
    config.time_zone = 'UTC'
    config.active_record.default_timezone :utc
  end
end

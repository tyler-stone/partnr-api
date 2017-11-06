require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)


module Partnr
  class Application < Rails::Application
    @@MAJOR_VERSION = '1'
    @@MINOR_VERSION = '3'
    @@PATCH_VERSION = '0'

    # use rspec for testing
    config.generators do |g|
      g.test_framework :rspec
    end

    # load the libraries
    config.autoload_paths += %W(#{config.root}/lib)

    # return the version number
    def version
      @@MAJOR_VERSION+'.'+@@MINOR_VERSION+'.'+@@PATCH_VERSION
    end

    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '*/')]
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]
    config.autoload_paths += Dir[Rails.root.join('app', 'api', 'v1', 'helpers')]
    config.autoload_paths += Dir[Rails.root.join('app', 'api', 'v1', 'entities')]
    config.autoload_paths += Dir[Rails.root.join('app', 'api', 'v1', 'entities', 'profile')]

    # specify middleware order so CORS is before warden (devise)
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*' # controlled at the nginx level
        resource 'api/*', :headers => :any, :methods => :any, :credentials => true, :max_age => 600
      end
    end
  end
end

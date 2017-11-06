require 'simplecov'

SimpleCov.start do
  add_filter do |file|
    file.lines.count < 5
    file.filename.include? "spec/"
  end

  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Helpers", "app/helpers"
  add_group "Config", "config"
end

require 'devise'
require 'json-schema-rspec'
require 'support/controller_macros'

RSpec.configure do |config|
  config.include Devise::TestHelpers
  config.include JSON::SchemaMatchers
  config.include Warden::Test::Helpers
  config.extend ControllerMacros, :type => :controller

  Warden.test_mode!

  Dir.new("./spec/schema/v1").each do |f|
    if f.index('.').nil?
      Dir.new("./spec/schema/v1/#{f}").each do |nest|
        config.json_schemas[File.basename(nest, ".*").to_sym] =
          File.absolute_path("./spec/schema/v1/#{f}/#{nest}")
      end
    else
      config.json_schemas[File.basename(f, ".*").to_sym] =
        File.absolute_path("./spec/schema/v1/#{f}")
    end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Print the 10 slowest examples at the end of the spec run
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies.
  config.order = :random

  Kernel.srand config.seed
end

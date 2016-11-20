ENV['RACK_ENV'] = 'test'

require 'proxes'
require 'proxes/db'
require 'rspec'
require 'rack/test'
require 'warden'
require 'factory_girl'
require 'database_cleaner'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Warden::Test::Helpers
  config.include FactoryGirl::Syntax::Methods

  config.alias_example_to :fit, focus: true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction

    FactoryGirl.find_definitions
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.after(:each) do
    Warden.test_reset!
  end
end

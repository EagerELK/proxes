# frozen_string_literal: true
ENV['RACK_ENV'] ||= 'test'
ENV['ELASTICSEARCH_URL'] = 'http://test.cluster:9200'

require 'simplecov'
SimpleCov.start

require 'proxes'
require 'proxes/db'
if ENV['DATABASE_URL'] == 'sqlite::memory:'
  folder = File.expand_path(File.dirname(__FILE__) + '/../migrate')
  Sequel.extension :migration
  Sequel::Migrator.apply(DB, folder)

  # Seed the DB
  require 'proxes/seed'
end

require 'rspec'
require 'rack/test'
require 'warden'
require 'factory_girl'
require 'database_cleaner'
require 'webmock/rspec'

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

    WebMock.disable_net_connect!
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

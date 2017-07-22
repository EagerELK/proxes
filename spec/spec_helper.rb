# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start

require 'proxes'
if ENV['DATABASE_URL'] == 'sqlite::memory:'
  folder = File.expand_path(File.dirname(__FILE__) + '/../migrate')
  Sequel.extension :migration
  Sequel::Migrator.apply(DB, folder)

  # Seed the DB
  require 'proxes/seed'
end

require 'rspec'
require 'rack/test'
require 'factory_girl'
require 'database_cleaner'
require 'timecop'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryGirl::Syntax::Methods

  config.alias_example_to :fit, focus: true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    FactoryGirl.find_definitions
    Timecop.freeze
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

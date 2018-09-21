# frozen_string_literal: true

ENV['APP_ENV'] ||= 'test'
ENV['RACK_ENV'] ||= 'test'
ENV['ELASTICSEARCH_URL'] ||= 'http://localhost:9200'
ENV['DATABASE_URL'] ||= 'sqlite::memory:'

# require 'simplecov'
# SimpleCov.start

require 'ditty'
require 'ditty/db'
require 'rspec'
require 'rspec_sequel_matchers'
require 'rack/test'
require 'factory_bot'
require 'database_cleaner'
require 'timecop'

if ENV['DATABASE_URL'] == 'sqlite::memory:'
  folder = File.expand_path(File.dirname(__FILE__) + '/../migrations')
  Sequel.extension :migration
  Sequel::Migrator.apply(DB, folder)
end

Ditty.component :app unless Ditty::Components.component? :app
Ditty.component :proxes unless Ditty::Components.component? :proxes

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RspecSequel::Matchers
  config.include FactoryBot::Syntax::Methods

  config.alias_example_to :fit, focus: true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    FactoryBot.find_definitions
    Timecop.freeze
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      ::Ditty::User.create_anonymous_user('anonymous@proxes.io')
      example.run
    end
  end
end

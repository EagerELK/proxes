# frozen_string_literal: true

require 'dotenv/load'

require 'rake'
require 'ditty'
require 'ditty/db' if ENV['DATABASE_URL']

require 'ditty/components/app'
Ditty.component :app

require 'proxes'
Ditty.component :proxes

require 'ditty/rake_tasks'
require 'bundler/gem_tasks' if File.exist? 'proxes.gemspec'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
end

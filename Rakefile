# frozen_string_literal: true

require 'dotenv/load'

require 'rake'
require 'ditty'
require 'ditty/db' if ENV['DATABASE_URL']
require 'ditty/components/app'
require 'proxes'

Ditty.component :app
Ditty.component :proxes

Ditty::Components.tasks
require 'bundler/gem_tasks' if File.exist? 'proxes.gemspec'
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
end

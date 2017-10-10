# frozen_string_literal: true

require 'rake'
require 'bundler/gem_tasks'
require 'ditty/rake_tasks'

require 'ditty'
require 'proxes'

Ditty.component :app
Ditty.component :proxes

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
end

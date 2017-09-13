# frozen_string_literal: true

require 'dotenv/load'
require 'rake'

require 'proxes/rake_tasks'
require 'proxes'
require 'proxes/proxes'
ProxES::Container.plugin(:proxes)

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
end

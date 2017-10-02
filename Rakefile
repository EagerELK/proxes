# frozen_string_literal: true

require 'dotenv/load'

require 'rake'
require 'proxes'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
end

require 'ditty/rake_tasks'

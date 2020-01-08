# frozen_string_literal: true

require 'dotenv/load'

require 'rake'
require 'ditty'
require 'ditty/db' if ENV['DATABASE_URL']
require 'ditty/components/ditty'
require 'proxes'

Ditty.component :ditty
Ditty.component :proxes

Ditty::Components.tasks
require 'bundler/gem_tasks' if File.exist? 'proxes.gemspec'
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError => e
  puts 'Not loading RSpec: ' + e.message
end

namespace :sequel do
  task :annotate do
    Dir['lib/proxes/models/*.rb'].each { |f| require_relative f }
    begin
      require 'sequel/annotate'
      Sequel::Annotate.annotate(Dir['lib/proxes/models/*.rb'], namespace: '::ProxES')
    rescue LoadError
      puts 'sequel-annotate gem not loaded'
    end
  end
end

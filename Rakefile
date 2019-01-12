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

require 'rake'
require 'rake/tasklib'

module ProxES
  class Tasks < ::Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)

    def install_tasks
      namespace :proxes do
        desc 'Generate the needed tokens'
        task :generate_tokens do
          require 'securerandom'
          File.write('.session_secret', SecureRandom.random_bytes(40))
          File.write('.token_secret', SecureRandom.random_bytes(40))
        end

        desc 'Migrate ProxES database to latest version'
        task :migrate do
          Rake::Task['proxes:migrate:up'].invoke
        end

        namespace :migrate do
          require_relative './db'
          Sequel.extension :migration
          folder = File.expand_path(File.dirname(__FILE__) + '/../../migrate')

          desc 'Check if the migration is current'
          task :check do
            Sequel::Migrator.check_current(DB, folder)
          end

          desc 'Migrate ProxES database to latest version'
          task :up do
            Sequel::Migrator.apply(DB, folder)
          end

          desc 'Roll back the ProxES database'
          task :down do
            Sequel::Migrator.apply(DB, folder, 0)
          end

          desc 'Reset the ProxES database'
          task :bounce do
            Sequel::Migrator.apply(DB, folder, 0)
            Sequel::Migrator.apply(DB, folder)
          end
        end
      end
    end
  end
end

ProxES::Tasks.new.install_tasks

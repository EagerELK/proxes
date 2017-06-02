# frozen_string_literal: true

require 'rake'
require 'rake/tasklib'
require 'highline'
require 'yaml'

module ProxES
  class Tasks < ::Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)

    CONFIG_PATH = File.expand_path('./config/config.yml')

    POSTGRES_PACKAGES = [
      'postgresql-common',
      'postgresql-9.5',
      'postgresql-client-9.5',
      'postgresql-contrib-9.5',
      'postgresql-9.5-plv8',
    ]


    def install_tasks
      namespace :proxes do
        task :config do
          cli = HighLine.new

          config = File.file?(CONFIG_PATH) ? YAML.load_file(CONFIG_PATH) : {}
          config['install_folder'] = cli.ask('To which folder should we install', String) do |q|
            q.default = config['install_folder'] || File.expand_path('~/proxes')
          end.to_s

          config['proxes_hostname'] = cli.ask('ProxES Hostname?', String).to_s

          # Port Config
          config['web_port'] = cli.ask('HTTP Port? [80]', Integer) {|q| q.default = config['web_port'] || 80}.to_i
          config['https_port'] = cli.ask('SSL Port? [443]', Integer) {|q| q.default = config['https_port'] || 443}.to_i

          # Certificate
          config['ssl_key_path'] = cli.ask('Path to SSL key', String) {|q| q.default = config['ssl_key_path']}.to_s
          config['ssl_cert_path'] = cli.ask('Path to SSL certificate', String) {|q| q.default = config['ssl_cert_path']}.to_s

          config['redis_url'] = cli.ask('Redis URL', String) do |q|
            q.default = config['redis_url'] || 'redis://localhost:6379'
          end.to_s
          config['elasticsearch_url'] = cli.ask('ElasticSearch URL', String) do |q|
            q.default = config['elasticsearch_url'] || 'http://localhost:9200'
          end.to_s

          # Database Setup
          config['db_name'] = cli.ask('Database Name', String) {|q| q.default = 'proxes'}.to_s
          config['db_username'] = cli.ask('Database Username', String) {|q| q.default = 'proxes'}.to_s
          config['db_password'] = cli.ask('Database Password', String).to_s
          config['database_url'] = cli.ask('Database URL', String) do |q|
            q.default = config['database_url'] || "postgres://#{config['db_username']}:#{config['db_password']}@localhost:5432/#{config['db_name']}"
          end.to_s

          File.open(CONFIG_PATH, 'w') {|f| f.write config.to_yaml }
        end

        task :setup_redhat do
          cli = HighLine.new
          config = YAML.load_file(CONFIG_PATH)
          # Redis
          if cli.ask('Install Redis Server? (y/n)') {|q| q.in = ['y', 'n']; q.default = ENV['REDIS_URL'].nil? ? 'y' : 'n' } == 'y'
            system 'sudo yum install epel-release'
            system 'sudo yum update'
            system 'sudo yum install -y redis'
            system 'sudo systemctl start redis'
            system 'sudo systemctl enable redis'
          end

          # Postgres
          if cli.ask('Install PostgreSQL Server? (y/n)') {|q| q.in = ['y', 'n']; q.default = ENV['REDIS_URL'].nil? ? 'y' : 'n'} == 'y'
            system 'sudo yum install -y postgresql-server postgresql-contrib'
          end

          if cli.ask('Setup the PostgreSQL User & DB? (y/n)') {|q| q.in = ['y', 'n']; q.default = 'y'} == 'y'
            system "sudo -u postgres createuser #{config['db_username']}"
            system "sudo -u postgres createdb -O #{config['db_username']} #{config['db_name']}"
            system "sudo -u postgres psql -c \"alter user #{config['db_username']} with encrypted password '#{config['db_password']}';\""
            system "sudo -u postgres psql -c \"grant all privileges on database #{config['db_name']} to #{config['db_username']};\""
          end

          # Certs
          if cli.ask('Get a cert through Lets Encrypt? (y/n)') {|q| q.in = ['y', 'n']; q.default = 'y'} == 'y'
            system 'sudo yum install epel-release'
            system 'sudo apt-get update'
            system 'sudo apt-get install -y certbot'
            system "sudo certbot -n certonly --standalone -d #{config['proxes_hostname']}"
            config['ssl_key_path'] = "/etc/letsencrypt/live/#{config['proxes_hostname']}/privkey.pem"
            config['ssl_cert_path'] = "/etc/letsencrypt/live/#{config['proxes_hostname']}/fullchain.pem"
          end

          # TODO: Write the .env file

          File.open(CONFIG_PATH, 'w') {|f| f.write config.to_yaml }
        end

        task :setup_debian do
          cli = HighLine.new
          config = YAML.load_file(CONFIG_PATH)

          # Redis
          if cli.ask('Install Redis Server? (y/n)') {|q| q.in = ['y', 'n']; q.default = ENV['REDIS_URL'].nil? ? 'y' : 'n' } == 'y'
            system 'sudo apt-get install -y redis-server'
          end

          # Postgres
          if cli.ask('Install PostgreSQL Server? (y/n)') {|q| q.in = ['y', 'n']; q.default = ENV['REDIS_URL'].nil? ? 'y' : 'n'} == 'y'
            system 'sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ACCC4CF8'
            unless File.file? '/etc/apt/sources.list.d/pgdg.list'
              system 'sudo sh -c \'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list\''
            end
            system 'sudo apt-get update'
            system 'sudo apt-get install -y ' + POSTGRES_PACKAGES.join(' ')
          end

          if cli.ask('Setup the PostgreSQL User & DB? (y/n)') {|q| q.in = ['y', 'n']; q.default = 'y'} == 'y'
            system "sudo -u postgres createuser #{config['db_username']}"
            system "sudo -u postgres createdb -O #{config['db_username']} #{config['db_name']}"
            system "sudo -u postgres psql -c \"alter user #{config['db_username']} with encrypted password '#{config['db_password']}';\""
            system "sudo -u postgres psql -c \"grant all privileges on database #{config['db_name']} to #{config['db_username']};\""
          end

          # Certs
          if cli.ask('Get a cert through Lets Encrypt? (y/n)') {|q| q.in = ['y', 'n']; q.default = 'y'} == 'y'
            system 'sudo add-apt-repository ppa:certbot/certbot'
            system 'sudo apt-get update'
            system 'sudo apt-get install -y certbot'
            system "sudo certbot -n certonly --standalone -d #{config['proxes_hostname']}"
            config['ssl_key_path'] = "/etc/letsencrypt/live/#{config['proxes_hostname']}/privkey.pem"
            config['ssl_cert_path'] = "/etc/letsencrypt/live/#{config['proxes_hostname']}/fullchain.pem"
          end

          # TODO: Write the .env file

          File.open(CONFIG_PATH, 'w') {|f| f.write config.to_yaml }
        end


        desc 'Generate the needed tokens'
        task :generate_tokens do
          puts 'Generating the ProxES tokens'
          require 'securerandom'
          File.write('.session_secret', SecureRandom.random_bytes(40))
          File.write('.token_secret', SecureRandom.random_bytes(40))
        end

        desc 'Seed the ProxES database'
        task :seed do
          puts 'Seeding the ProxES database'
          require 'proxes/seed'
        end

        desc 'Prepare ProxES migrations'
        task :prep do
          puts 'Preparing the ProxES migrations folder'
          Dir.mkdir 'migrations' unless File.exist?('migrations')
          ::ProxES::Container.migrations.each do |path|
            FileUtils.cp_r "#{path}/.", 'migrations'
          end
        end

        desc 'Migrate ProxES database to latest version'
        task :migrate do
          puts 'Running the ProxES migrations'
          Rake::Task['proxes:migrate:up'].invoke
        end

        namespace :migrate do
          require_relative './db' if ENV['DATABASE_URL']
          folder = 'migrations'

          desc 'Check if the migration is current'
          task :check do
            Sequel.extension :migration
            Sequel::Migrator.check_current(DB, folder)
          end

          desc 'Migrate ProxES database to latest version'
          task :up do
            Sequel.extension :migration
            Sequel::Migrator.apply(DB, folder)
          end

          desc 'Roll back the ProxES database'
          task :down do
            Sequel.extension :migration
            Sequel::Migrator.apply(DB, folder, 0)
          end

          desc 'Reset the ProxES database'
          task :bounce do
            Sequel.extension :migration
            Sequel::Migrator.apply(DB, folder, 0)
            Sequel::Migrator.apply(DB, folder)
          end
        end
      end
    end
  end
end

ProxES::Tasks.new.install_tasks

# frozen_string_literal: true
require 'sequel'
require 'logger'

# Delete DATABASE_URL from the environment, so it isn't accidently
# passed to subprocesses.  DATABASE_URL may contain passwords.
DB = Sequel.connect(ENV['RACK_ENV'] == 'production' ? ENV.delete('DATABASE_URL') : ENV['DATABASE_URL'])

DB.loggers << Logger.new($stdout)

DB.extension(:pagination)

Sequel::Model.plugin :auto_validations
# Sequel::Model.plugin :prepared_statements
# Sequel::Model.plugin :prepared_statements_associations
Sequel::Model.plugin :timestamps, update_on_create: true

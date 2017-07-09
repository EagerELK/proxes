# frozen_string_literal: true

require 'sequel'
require 'proxes/services/logger'

# Delete DATABASE_URL from the environment, so it isn't accidently
# passed to subprocesses.  DATABASE_URL may contain passwords.
DB = Sequel.connect(ENV['RACK_ENV'] == 'production' ? ENV.delete('DATABASE_URL') : ENV['DATABASE_URL'])

DB.loggers << ProxES::Services::Logger.instance

DB.extension(:pagination)

Sequel::Model.plugin :auto_validations
Sequel::Model.plugin :update_or_create
Sequel::Model.plugin :timestamps, update_on_create: true

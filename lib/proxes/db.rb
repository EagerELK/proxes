require 'sequel'
require 'logger'

# Delete DATABASE_URL from the environment, so it isn't accidently
# passed to subprocesses.  DATABASE_URL may contain passwords.
DB = Sequel.connect(ENV.delete('DATABASE_URL'))

DB.loggers << Logger.new($stdout)

Sequel::Model.plugin :auto_validations
Sequel::Model.plugin :prepared_statements
Sequel::Model.plugin :prepared_statements_associations
Sequel::Model.plugin :timestamps, update_on_create: true

# Models
require 'proxes/models/user'
require 'proxes/models/identity'

require 'proxes/policies/user_policy'
require 'proxes/policies/token_policy'
require 'proxes/policies/identity_policy'

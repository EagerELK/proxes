# frozen_string_literal: true
#\-o 0.0.0.0 -p 9294
libdir = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

raise 'Unconfigured' unless ENV['ELASTICSEARCH_URL']

require 'proxes'
require 'proxes/db'

Sequel.extension :migration
Sequel::Migrator.check_current(DB, './migrate')

use Rack::Static, urls: ['/css', '/js'], root: 'public'
use Rack::MethodOverride
use Rack::Session::Cookie,
    key: '_ProxES_session',
    #:secure=>!TEST_MODE, # Uncomment if only allowing https:// access
    secret: File.read('.session_secret')

require 'omniauth'
require 'omniauth-identity'
require 'proxes/models/identity'
require 'proxes/controllers/auth_identity'
# OmniAuth.config.test_mode = true
use OmniAuth::Builder do
  # The identity provider is used by the App.
  provider :identity,
           fields: [:username],
           callback_path: '/_proxes/auth/identity/callback',
           model: ProxES::Identity,
           on_login: ProxES::AuthIdentity,
           on_registration: ProxES::AuthIdentity,
           locate_conditions: ->(req) { { username: req['username'] } }
end
OmniAuth.config.on_failure = ProxES::AuthIdentity

require 'warden'
require 'proxes/strategies/jwt_token'
use Warden::Manager do |manager|
  manager.default_strategies :jwt_token
  manager.scope_defaults :default, action: '_proxes/unauthenticated'
  manager.failure_app = ProxES::App
end
Warden::Manager.serialize_into_session(&:id)
Warden::Manager.serialize_from_session { |id| ProxES::User[id] }

# Management App
require 'proxes/controllers'

map '/_proxes' do
  {
    '/users' => ProxES::Users,
    '/user-roles' => ProxES::UserRoles
  }.each do |route, app|
    map route do
      run app
    end
  end

  run ProxES::App
end

# Proxy all Elasticsearch requests
map '/' do
  # Security
  use ProxES::Security, Logger.new($stdout)

  # Forward requests to ES
  run Rack::Proxy.new(backend: ENV['ELASTICSEARCH_URL'])
end

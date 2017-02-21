# frozen_string_literal: true
#\-o 0.0.0.0 -p 9294
libdir = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

raise 'Unconfigured' unless ENV['ELASTICSEARCH_URL']

require 'proxes'
require 'proxes/db'
require 'proxes/app'
require 'proxes/listener'

Sequel.extension :migration
Sequel::Migrator.check_current(DB, './migrate')

use Rack::Static, urls: ['/css', '/js'], root: 'public'
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

# Management App
Dir.glob("#{libdir}/proxes/controllers/*.rb").each { |file| require file }

map '/_proxes' do
  {
    '/users' => ProxES::Users,
    '/roles' => ProxES::Roles,
    '/permissions' => ProxES::Permissions,
    '/audit-logs' => ProxES::AuditLogs,
  }.each do |route, app|
    map route do
      run app
    end
  end

  run ProxES::App
end

# Proxy all Elasticsearch requests
require 'proxes/security'
map '/' do
  # Security
  use ProxES::Security, ProxES::Services::Logger.instance

  # Forward requests to ES
  run Rack::Proxy.new(backend: ENV['ELASTICSEARCH_URL'])
end

# frozen_string_literal: true
libdir = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

raise 'Unconfigured' unless ENV['ELASTICSEARCH_URL']

require 'proxes'
require 'proxes/omniauth'
use Rack::Session::Cookie,
    key: '_ProxES_session',
    #:secure=>!TEST_MODE, # Uncomment if only allowing https:// access
    secret: File.read('.session_secret')

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
map '/_proxes' do
  run Rack::URLMap.new ProxES::Container.routes
end

# Proxy all Elasticsearch requests
require 'proxes/security'
require 'proxes/forwarder'
map '/' do
  # Security
  use ProxES::Security, ProxES::Services::Logger.instance
  use Rack::ContentLength

  # Forward requests to ES
  run ProxES::Forwarder.new(backend: ENV['ELASTICSEARCH_URL'])
end

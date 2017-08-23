# frozen_string_literal: true
libdir = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'dotenv/load'
require 'proxes'
require 'proxes/proxes'
require 'rack/protection'
ProxES::Container.plugin(:proxes)

use Rack::Session::Cookie,
    key: '_ProxES_session',
    # :secure=>!TEST_MODE, # Uncomment if only allowing https:// access
    secret: File.read('.session_secret')
use Rack::Protection::RemoteToken
use Rack::Protection::SessionHijacking

map '/_proxes' do
  require 'proxes/omniauth'

  use OmniAuth::Builder do
    configure do |config|
      config.path_prefix = '/auth'
      config.on_failure = ProxES::App
    end

    # The identity provider is used by the App.
    provider :identity,
             fields: [:username],
             callback_path: '/auth/identity/callback',
             model: ProxES::Identity,
             on_login: ProxES::App,
             on_registration: ProxES::App,
             locate_conditions: ->(req) { { username: req['username'] } }
  end

  run Rack::URLMap.new ProxES::Container.routes
end

map '/' do
  # Proxy all Elasticsearch requests
  require 'proxes/security'
  require 'proxes/forwarder'

  # Security
  use ProxES::Security, ProxES::Services::Logger.instance
  use Rack::ContentLength

  # Forward requests to ES
  run ProxES::Forwarder.new(backend: ENV['ELASTICSEARCH_URL'])
end

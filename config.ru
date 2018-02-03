# frozen_string_literal: true

libdir = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'dotenv/load'

# Session
use Rack::Session::Cookie,
    key: '_ProxES_session',
    path: '/',
    # :secure=>!TEST_MODE, # Uncomment if only allowing https:// access
    secret: File.read('.session_secret')

# Rack Protection
require 'rack/protection'
use Rack::Protection::RemoteToken
use Rack::Protection::SessionHijacking

map '/_proxes' do
  require 'ditty/components/app'
  Ditty.component :app

  require 'ditty/controllers/application'
  Ditty::Application.set :map_path, '/_proxes'

  require 'omniauth'
  require 'omniauth/identity'
  OmniAuth.config.logger = Ditty::Services::Logger.instance
  OmniAuth.config.on_failure = proc { |env|
    OmniAuth::FailureEndpoint.new(env).redirect_to_failure
  }

  require 'ditty/controllers/main'
  require 'ditty/models/identity'
  use OmniAuth::Builder do
    # The identity provider is used by the App.
    provider :identity,
             fields: [:username],
             callback_path: '/auth/identity/callback',
             model: Ditty::Identity,
             on_login: Ditty::Main,
             on_registration: Ditty::Main,
             locate_conditions: ->(req) { { username: req['username'] } }
  end

  # Management App
  require 'proxes'
  Ditty.component :proxes

  run Rack::URLMap.new Ditty::Components.routes
end

map '/' do
  # Proxy all Elasticsearch requests
  require 'proxes/security'
  require 'proxes/forwarder'

  # Security
  use ProxES::Security, Ditty::Services::Logger.instance
  use Rack::ContentLength

  # Forward requests to ES
  run ProxES::Forwarder.instance
end

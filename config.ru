# frozen_string_literal: true

require 'dotenv/load'

# Session
use Rack::Session::Cookie,
    key: '_ProxES_session',
    path: '/',
    # :secure=>!TEST_MODE, # Uncomment if only allowing https:// access
    secret: File.read('.session_secret')

require './application'
require 'ditty/services/authentication'
use OmniAuth::Builder do
  Ditty::Services::Authentication.config.each do |prov, config|
    provider prov, *config[:arguments]
  end
end

map '/_proxes' do
  run Rack::URLMap.new Ditty::Components.routes
end

map '/' do
  # Proxy all Elasticsearch requests
  require 'ditty/services/logger'
  require 'proxes/middleware/metrics'
  require 'proxes/middleware/error_handling'
  require 'proxes/middleware/security'
  require 'proxes/forwarder'

  # Security
  use ProxES::Middleware::Metrics
  use ProxES::Middleware::ErrorHandling
  use ProxES::Middleware::Security, Ditty::Services::Logger.instance unless ENV['PROXES_PASSTHROUGH']
  use Rack::ContentLength

  # Forward requests to ES
  run ProxES::Forwarder.instance
end

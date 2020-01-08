# frozen_string_literal: true

require 'dotenv/load'

# Last Gasp Effort to catch the error
require 'ditty/middleware/error_catchall'
use ::Ditty::Middleware::ErrorCatchall if ENV['APP_ENV'] == 'production'

use Rack::Static, root: 'public', urls: ['/favicon.ico', '/css', '/images', '/js'], header_rules: [
  [:all, { 'Cache-Control' => 'public, max-age=31536000' }]
]

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
  require 'ditty/middleware/accept_extension'
  require 'rack/content_type'

  use Ditty::Middleware::AcceptExtension
  use Rack::ContentType
  run Rack::URLMap.new Ditty::Components.routes
end

map '/' do
  # Proxy all Elasticsearch requests
  require 'ditty/services/logger'
  require 'proxes/forwarder'
  require 'proxes/middleware/error_handling'
  require 'proxes/middleware/metrics'

  # Security
  use ProxES::Middleware::Metrics
  use ProxES::Middleware::ErrorHandling
  use Rack::ContentLength

  # Forward requests to ES
  run ProxES::Forwarder.instance
end

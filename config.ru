#\-o 0.0.0.0 -p 9292
libdir = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'proxes'
require 'proxes/db'

use Rack::Session::Pool
# use Rack::Session::Cookie,
#   :key => '_ProxES_session',
#   #:secure=>!TEST_MODE, # Uncomment if only allowing https:// access
#   :secret=>File.read('.session_secret')

require 'omniauth'
require 'omniauth-identity'
# OmniAuth.config.test_mode = true

use OmniAuth::Builder do
  # The identity provider is used by the App.
  provider :identity,
    fields: [:username],
    model: ProxES::Identity,
    on_login: ProxES::Security,
    on_registration: ProxES::Security,
    locate_conditions: lambda{|req| {username: req['username']} }
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

require 'warden'
require 'proxes/strategies/jwt_token'
use Warden::Manager do |manager|
  manager.default_strategies :jwt_token
  manager.scope_defaults :default, action: '_proxes/unauthenticated'
  manager.failure_app = ProxES::Security
end

Warden::Manager.serialize_into_session { |user| user.id }
Warden::Manager.serialize_from_session { |id| ProxES::User[id] }

# Proxy all Elasticsearch requests
map '/' do
  # Security
  use ProxES::Security

  # Forward requests to ES
  run Rack::Proxy.new(backend: ENV['ELASTICSEARCH_URL'])
end

# Management App
map '/_proxes' do
  run ProxES::App
end

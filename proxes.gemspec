# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'proxes/version'

Gem::Specification.new do |spec|
  spec.name          = 'proxes'
  spec.version       = ProxES::VERSION
  spec.authors       = ['Jurgens du Toit']
  spec.email         = ['jrgns@jadeit.co.za']

  spec.summary       = 'Rack wrapper around Elasticsearch to provide security and management features'
  spec.description   = 'Rack wrapper around Elasticsearch to provide security and management features'
  spec.homepage      = 'https://github.com/eagerelk/proxes'
  spec.license       = 'LGPL-3.0'

  spec.files         = Dir['lib/**/*.rb'] + Dir['bin/*'] + Dir['migrate/*'] + Dir['views/**.*'] + Dir['public/**.*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'racksh'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_sequel_matchers', '~> 0.4.0'
  spec.add_development_dependency 'sequel-annotate'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'webmock'

  spec.add_dependency 'activesupport', '>= 3'
  spec.add_dependency 'bcrypt', '~> 3.1'
  spec.add_dependency 'ditty', '>= 0.7.0'
  spec.add_dependency 'elasticsearch', '>= 2'
  spec.add_dependency 'faraday'
  spec.add_dependency 'haml', '~> 5.0'
  spec.add_dependency 'highline', '~> 1.7'
  spec.add_dependency 'logger', '~> 1.0'
  spec.add_dependency 'net-http-persistent'
  spec.add_dependency 'omniauth', '~> 1.0'
  spec.add_dependency 'omniauth-http-basic', '~> 1.0'
  spec.add_dependency 'omniauth-identity', '~> 1.0'
  spec.add_dependency 'pundit', '~> 1.0'
  spec.add_dependency 'rack-contrib', '~> 1.0'
  spec.add_dependency 'rake', '~> 12.0'
  spec.add_dependency 'sequel', '~> 4.0'
  spec.add_dependency 'sinatra', '~> 2.0'
  spec.add_dependency 'sinatra-contrib', '~> 2.0'
  spec.add_dependency 'sinatra-flash', '~> 0.3'
  spec.add_dependency 'tilt', '>= 2'
  spec.add_dependency 'wisper', '~> 2.0'
end

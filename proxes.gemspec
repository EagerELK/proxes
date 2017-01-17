# coding: utf-8
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
  spec.license       = 'LGPLv3'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'racksh'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'factory_girl'

  spec.add_dependency 'rack-proxy'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'sinatra-flash'
  spec.add_dependency 'sinatra-contrib'
  spec.add_dependency 'elasticsearch'
  spec.add_dependency 'logger'
  spec.add_dependency 'pundit'
  spec.add_dependency 'sequel'
  spec.add_dependency 'bcrypt'
  spec.add_dependency 'omniauth'
  spec.add_dependency 'omniauth-identity'
  spec.add_dependency 'warden'
  spec.add_dependency 'jwt'
  spec.add_dependency 'haml'
  spec.add_dependency 'tilt', '>= 2'
end

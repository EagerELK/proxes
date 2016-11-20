require 'rack-proxy'
require 'proxes/es_request'
require 'proxes/policies/es_policy'
require 'proxes/helpers/pundit'
require 'proxes/helpers/authentication'

module ProxES
  class Security
    attr_reader :env

    include ProxES::Helpers::Authentication
    include ProxES::Helpers::Pundit

    def initialize(app)
      @app = app
    end

    def call(env)
      @env = env

      request = ProxES::ESRequest.new(env)

      unless ENV['RACK_ENV'] == 'production'
        puts '================================================================================'
        puts '= ' + "Request: #{request.fullpath}".ljust(76) + '='
        puts '= ' + "Endpoint: #{request.endpoint}".ljust(76) + '='
        puts '= ' + "Index: #{request.index}".ljust(76) + '='
        puts '= ' + "Type: #{request.type}".ljust(76) + '='
        puts '= ' + "Action: #{request.action}".ljust(76) + '='
        puts '================================================================================'
      end

      if request.has_indices?
        policy_scope request
      else
        authorize request
      end

      unless ENV['RACK_ENV'] == 'production'
        puts '================================================================================'
        puts '= ' + "Request: #{request.fullpath}".ljust(76) + '='
        puts '= ' + "Endpoint: #{request.endpoint}".ljust(76) + '='
        puts '= ' + "Index: #{request.index}".ljust(76) + '='
        puts '= ' + "Type: #{request.type}".ljust(76) + '='
        puts '= ' + "Action: #{request.action}".ljust(76) + '='
        puts '================================================================================'
      end

      @app.call env
    end
  end
end

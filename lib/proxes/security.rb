require 'logger'
require 'rack-proxy'
require 'proxes/request'
require 'proxes/policies/request_policy'
require 'proxes/helpers/pundit'
require 'proxes/helpers/authentication'

module ProxES
  class Security
    attr_reader :env, :logger

    include ProxES::Helpers::Authentication
    include ProxES::Helpers::Pundit

    def initialize(app, logger = nil)
      @app = app
      @logger = logger || Logger.new(nil)
    end

    def call(env)
      @env = env

      request = ProxES::Request.from_env(env)

      logger.debug '================================================================================'
      logger.debug '= ' + "Request: #{request.fullpath}".ljust(76) + ' ='
      logger.debug '= ' + "Endpoint: #{request.endpoint}".ljust(76) + ' ='
      logger.debug '================================================================================'

      authorize request
      if request.has_indices?
        policy_scope request
      end

      logger.debug '================================================================================'
      logger.debug '= ' + "Request: #{request.fullpath}".ljust(76) + ' ='
      logger.debug '= ' + "Endpoint: #{request.endpoint}".ljust(76) + ' ='
      logger.debug '================================================================================'

      @app.call env
    end
  end
end

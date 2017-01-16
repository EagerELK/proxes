# frozen_string_literal: true
require 'proxes/services/logger'
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
      @logger = logger || ProxES::Services::Logger.instance
    end

    def call(env)
      @env = env

      request = ProxES::Request.from_env(env)

      logger.debug '================================================================================'
      logger.debug '= ' + "Request: #{request.fullpath}".ljust(76) + ' ='
      logger.debug '= ' + "Endpoint: #{request.endpoint}".ljust(76) + ' ='
      logger.debug '================================================================================'

      authorize request
      policy_scope request if request.indices?

      logger.debug '================================================================================'
      logger.debug '= ' + "Request: #{request.fullpath}".ljust(76) + ' ='
      logger.debug '= ' + "Endpoint: #{request.endpoint}".ljust(76) + ' ='
      logger.debug '================================================================================'

      begin
        @app.call env
      rescue Errno::EHOSTUNREACH
        message = 'Could not reach Elasticsearch at ' + ENV['ELASTICSEARCH_URL']
        [500, { 'Content-Type' => 'application/json' }, ['{"error":"' + message + '}']]
      rescue Errno::ECONNREFUSED
        message = 'Elasticsearch not listening at ' + ENV['ELASTICSEARCH_URL']
        [500, { 'Content-Type' => 'application/json' }, ['{"error":"' + message + '}']]
      end
    end
  end
end

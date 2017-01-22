# frozen_string_literal: true
require 'proxes/services/logger'
require 'rack-proxy'
require 'proxes/request'
require 'proxes/policies/request_policy'
require 'proxes/helpers/pundit'
require 'proxes/helpers/authentication'
require 'proxes/services/logger'

module ProxES
  class Security
    attr_reader :env, :logger

    include ProxES::Helpers::Authentication
    include ProxES::Helpers::Pundit

    def initialize(app, logger = nil)
      @app = app
      @logger = logger || ProxES::Services::Logger.instance
    end

    def error(message, code = 500)
      [code, { 'Content-Type' => 'application/json' }, ['{"error":"' + message + '}']]
    end

    def call(env)
      @env = env

      request = ProxES::Request.from_env(env)

      logger.debug '==========================BEFORE================================================'
      logger.debug '= ' + "Request: #{request.fullpath}".ljust(76) + ' ='
      logger.debug '= ' + "Endpoint: #{request.endpoint}".ljust(76) + ' ='
      logger.debug '================================================================================'

      begin
        authorize request
      rescue StandardError => e
        logger.debug "Access denied by security layer: #{e.message}"
        return error 'Forbidden', 403
      end
      request.index = policy_scope(request) if request.indices?

      logger.debug '==========================AFTER================================================='
      logger.debug '= ' + "Request: #{request.fullpath}".ljust(76) + ' ='
      logger.debug '= ' + "Endpoint: #{request.endpoint}".ljust(76) + ' ='
      logger.debug '================================================================================'

      begin
        @app.call request.env
      rescue Errno::EHOSTUNREACH
        error 'Could not reach Elasticsearch at ' + ENV['ELASTICSEARCH_URL']
      rescue Errno::ECONNREFUSED
        error 'Elasticsearch not listening at ' + ENV['ELASTICSEARCH_URL']
      end
    end
  end
end

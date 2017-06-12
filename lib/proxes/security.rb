# frozen_string_literal: true

require 'proxes/services/logger'
require 'proxes/request'
require 'proxes/policies/request_policy'
require 'proxes/helpers/pundit'
require 'proxes/helpers/authentication'
require 'proxes/helpers/wisper'
require 'proxes/services/logger'

module ProxES
  class Security
    attr_reader :env, :logger

    include Helpers::Authentication
    include Helpers::Pundit
    include Helpers::Wisper
    include Wisper::Publisher

    def initialize(app, logger = nil)
      @app = app
      @logger = logger || Services::Logger.instance
    end

    def error(message, code = 500)
      [code, { 'Content-Type' => 'application/json' }, ['{"error":"' + message + '"}']]
    end

    def call(env)
      @env = env

      request = Request.from_env(env)

      logger.debug '==========================BEFORE================================================'
      logger.debug '= ' + "Request: #{request.fullpath}".ljust(76) + ' ='
      logger.debug '= ' + "Endpoint: #{request.endpoint}".ljust(76) + ' ='
      logger.debug '================================================================================'

      begin
        check_basic
        authorize request
      rescue StandardError
        log_action(:es_request_denied, details: "#{request.request_method.upcase} #{request.fullpath} (#{request.class.name})")
        logger.debug "Access denied for #{current_user ? current_user.email : 'Anonymous User'} by security layer: #{request.request_method.upcase} #{request.fullpath} (#{request.class.name})"
        return error 'Forbidden', 403
      end
      request.index = policy_scope(request) if request.indices?

      logger.debug '==========================AFTER================================================='
      logger.debug '= ' + "Request: #{request.fullpath}".ljust(76) + ' ='
      logger.debug '= ' + "Endpoint: #{request.endpoint}".ljust(76) + ' ='
      logger.debug '================================================================================'

      begin
        start = Time.now.to_f
        result = @app.call request.env
        broadcast(:call_completed, endpoint: request.endpoint, duration: Time.now.to_f - start)
        result
      rescue Errno::EHOSTUNREACH
        error 'Could not reach Elasticsearch at ' + ENV['ELASTICSEARCH_URL']
      rescue Errno::ECONNREFUSED
        error 'Elasticsearch not listening at ' + ENV['ELASTICSEARCH_URL']
      end
    end
  end
end

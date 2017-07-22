# frozen_string_literal: true

require 'proxes/models/identity'
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
      headers = { 'Content-Type' => 'application/json' }
      headers['WWW-Authenticate'] = 'Basic realm="security"' if code == 401
      [code, headers, ['{"error":"' + message + '"}']]
    end

    def check(request)
      check_basic request
      authorize request
    rescue Pundit::NotAuthorizedError
      log_action(:es_request_denied, details: "#{request.request_method.upcase} #{request.fullpath} (#{request.class.name})")
      logger.debug "Access denied for #{current_user ? current_user.email : 'Anonymous User'} by security layer: #{request.request_method.upcase} #{request.fullpath} (#{request.class.name})"
      error 'Not Authorized', 401
    rescue ::ProxES::Helpers::NotAuthenticated
      logger.warn "Access denied for unauthenticated request by security layer: #{request.request_method.upcase} #{request.fullpath} (#{request.class.name})"
      error 'Not Authenticated', 401
    rescue StandardError => e
      raise e if env['RACK_ENV'] != 'production'
      logger.error "Access denied for #{current_user ? current_user.email : 'Anonymous User'} by security exception: #{request.request_method.upcase} #{request.fullpath} (#{request.class.name})"
      logger.error e
      error 'Forbidden', 403
    end

    def forward(request)
      start = Time.now.to_f
      result = @app.call request.env
      broadcast(:call_completed, endpoint: request.endpoint, duration: Time.now.to_f - start)
      result
    rescue Errno::EHOSTUNREACH
      error 'Could not reach Elasticsearch at ' + env['ELASTICSEARCH_URL']
    rescue Errno::ECONNREFUSED
      error 'Elasticsearch not listening at ' + env['ELASTICSEARCH_URL']
    end

    def call(env)
      @env = env

      request = Request.from_env(env)
      broadcast(:call_started, request)

      logger.debug '==========================BEFORE================================================'
      logger.debug '= ' + "Request: #{request.request_method} #{request.fullpath} (#{request.class.name})".ljust(76) + ' ='
      logger.debug '= ' + "Endpoint: #{request.endpoint}".ljust(76) + ' ='
      logger.debug '================================================================================'

      unless env['PROXES_PASSTHROUGH']
        result = check(request)
        return result if result.is_a?(Array) # Rack Response

        request.index = policy_scope(request) if request.indices?
      end

      logger.debug '==========================AFTER================================================='
      logger.debug '= ' + "Request: #{request.request_method} #{request.fullpath} (#{request.class.name})".ljust(76) + ' ='
      logger.debug '= ' + "Endpoint: #{request.endpoint}".ljust(76) + ' ='
      logger.debug '================================================================================'

      forward request
    end
  end
end

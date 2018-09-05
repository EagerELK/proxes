# frozen_string_literal: true

require 'wisper'
require 'proxes/request'
require 'ditty/services/logger'

module ProxES
  module Middleware
    class ErrorHandling
      attr_reader :logger

      include Wisper::Publisher

      def initialize(app, logger = nil)
        @app = app
        @logger = logger || ::Ditty::Services::Logger.instance
      end

      def call(env)
        request = ProxES::Request.from_env(env)
        response = @app.call env
        broadcast(:es_request_failed, request, response) unless (200..299).cover?(response[0])
        response
      rescue Errno::EHOSTUNREACH
        error 'Could not reach Elasticsearch at ' + ENV['ELASTICSEARCH_URL']
      rescue Errno::ECONNREFUSED, Faraday::ConnectionFailed, SocketError
        error 'Elasticsearch not listening at ' + ENV['ELASTICSEARCH_URL']
      rescue Pundit::NotAuthorizedError, Ditty::Helpers::NotAuthenticated => e
        broadcast(:es_request_denied, request, e)
        log_not_authorized request
        raise e if ENV['APP_ENV'] == 'development'
        return [401, {}, []] if request.head?
        request.html? && request.user.nil? ? login_and_redirect(request) : error('Not Authorized', 401)
      rescue StandardError => e
        broadcast(:es_request_denied, request, e)
        log_not_authorized request
        raise e if ENV['APP_ENV'] == 'development'
        return [403, {}. []] if request.head?
        error 'Forbidden', 403
      end

      def log_not_authorized(request)
        user = request.user ? request.user.email : 'unauthenticated request'
        logger.error "Access denied for #{user} by security layer: #{request.detail}"
      end

      # Response Helpers
      def error(message, code = 500)
        headers = { 'Content-Type' => 'application/json' }
        headers['WWW-Authenticate'] = 'Basic realm="security"' if code == 401
        [code, headers, ['{"error":"' + message + '"}']]
      end

      def login_and_redirect(request)
        request.session['omniauth.origin'] = request.url unless request.url == '/_proxes/auth/login'
        redirect '/_proxes/auth/login'
      end

      def redirect(destination, code = 302)
        [code, { 'Location' => destination }, []]
      end
    end
  end
end

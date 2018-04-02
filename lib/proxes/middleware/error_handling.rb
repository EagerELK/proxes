# frozen_string_literal: true

require 'ditty/helpers/wisper'

module ProxES
  module Middleware
    class ErrorHandling
      attr_reader :logger

      include Wisper::Publisher
      include Ditty::Helpers::Wisper

      def initialize(app, logger = nil)
        @app = app
        @logger = logger || ::Ditty::Services::Logger.instance
      end

      def call(env)
        request = Request.from_env(env)
        @app.call env
      rescue Errno::EHOSTUNREACH
        error 'Could not reach Elasticsearch at ' + ENV['ELASTICSEARCH_URL']
      rescue Errno::ECONNREFUSED, Faraday::ConnectionFailed
        error 'Elasticsearch not listening at ' + ENV['ELASTICSEARCH_URL']
      rescue Pundit::NotAuthorizedError, Ditty::Helpers::NotAuthenticated
        if request.html? && request.user.nil?
          env['rack.session']['omniauth.origin'] = request.url
          return redirect '/_proxes/auth/identity'
        end

        log_action(
          :es_request_denied,
          user: request.user,
          details: "#{request.request_method.upcase} #{request.fullpath} (#{request.class.name})"
        )
        user = request.user ? request.user.email : 'unauthenticated request'
        logger.debug "Access denied for #{user} by security layer: #{request.detail}"
        error 'Not Authorized', 401
      rescue StandardError => e
        raise e if env['RACK_ENV'] != 'production'
        user = request.user ? request.user.email : 'unauthenticated request'
        logger.error "Access denied for #{user} by security exception: #{request.detail}"
        logger.error e
        error 'Forbidden', 403
      end

      # Response Helpers
      def error(message, code = 500)
        headers = { 'Content-Type' => 'application/json' }
        headers['WWW-Authenticate'] = 'Basic realm="security"' if code == 401
        [code, headers, ['{"error":"' + message + '"}']]
      end

      def redirect(destination, code = 302)
        [code, { 'Location' => destination }, []]
      end
    end
  end
end

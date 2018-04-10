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
        code, headers, body = @app.call env
        unless (200..299).cover? code
          log_action(
            :es_request_failed,
            user: request.user,
            details: "#{request.request_method.upcase} #{request.fullpath} (#{request.class.name})"
          )
        end
        [code, headers, body]
      rescue Errno::EHOSTUNREACH
        error 'Could not reach Elasticsearch at ' + ENV['ELASTICSEARCH_URL']
      rescue Errno::ECONNREFUSED, Faraday::ConnectionFailed
        error 'Elasticsearch not listening at ' + ENV['ELASTICSEARCH_URL']
      rescue Pundit::NotAuthorizedError, Ditty::Helpers::NotAuthenticated
        if request.html? && request.user.nil?
          env['rack.session']['omniauth.origin'] = request.url
          return redirect '/_proxes/auth/identity'
        end

        user = request.user ? request.user.email : 'unauthenticated request'
        logger.error "Access denied for #{user} by security layer: #{request.detail}"

        failed request, 'Not Authorized', :es_request_denied, 401
      rescue StandardError => e
        raise e if env['RACK_ENV'] != 'production'

        user = request.user ? request.user.email : 'unauthenticated request'
        logger.error "Access denied for #{user} by security exception: #{request.detail}"
        logger.error e

        failed request, 'Forbidden', :es_request_denied, 403
      end

      def failed(request, message, action, code)
        log_action(
          action,
          user: request.user,
          details: "#{request.request_method.upcase} #{request.fullpath} (#{request.class.name})"
        )
        error message, code
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

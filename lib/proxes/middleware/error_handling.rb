# frozen_string_literal: true

module ProxES
  module Middleware
    class ErrorHandling
      attr_reader :env

      def initialize(app, logger = nil)
        @app = app
        @logger = logger || ::Ditty::Services::Logger.instance
      end

      def call(env)
        @env = env
        request = Request.from_env(env)
        @app.call env
      rescue Errno::EHOSTUNREACH
        error 'Could not reach Elasticsearch at ' + ENV['ELASTICSEARCH_URL']
      rescue Errno::ECONNREFUSED, Faraday::ConnectionFailed
        error 'Elasticsearch not listening at ' + ENV['ELASTICSEARCH_URL']
      rescue Pundit::NotAuthorizedError
        if html? request
          env['rack.session']['omniauth.origin'] = request.url
          return redirect '/_proxes/auth/identity'
        end

        log_action(:es_request_denied, details: "#{request.request_method.upcase} #{request.fullpath} (#{request.class.name})")
        logger.debug "Access denied for #{current_user ? current_user.email : 'Anonymous User'} by security layer: #{request.request_method.upcase} #{request.fullpath} (#{request.class.name})"
        error 'Not Authorized', 401
      rescue ::Ditty::Helpers::NotAuthenticated
        logger.warn "Access denied for unauthenticated request by security layer: #{request.request_method.upcase} #{request.fullpath} (#{request.class.name})"
        error 'Not Authenticated', 401
      rescue StandardError => e
        raise e if env['RACK_ENV'] != 'production'
        logger.error "Access denied for #{current_user ? current_user.email : 'Anonymous User'} by security exception: #{request.request_method.upcase} #{request.fullpath} (#{request.class.name})"
        logger.error e
        error 'Forbidden', 403
      end

      # Request Helpers
      def html?(request)
        request.get_header('HTTP_ACCEPT') && request.get_header('HTTP_ACCEPT').include?('text/html')
      end

      # Response Helpers
      def error(message, code = 500)
        headers = { 'Content-Type' => 'application/json' }
        headers['WWW-Authenticate'] = 'Basic realm="security"' if code == 401
        [code, headers, ['{"error":"' + message + '"}']]
      end

      def redirect(destination, code = 302)
        [code, { 'Location' => destination}, []]
      end
    end
  end
end

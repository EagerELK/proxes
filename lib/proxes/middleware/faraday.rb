# frozen_string_literal: true

require 'pundit'
require 'faraday'
require 'proxes/policies/request_policy'

module ProxES
  module Middleware
    class Faraday < Faraday::Middleware
      def logger
        @logger ||= ::Ditty::Services::Logger
      end

      def call(request_env)
        request = ProxES::Request.from_env(env_from_faraday(request_env))

        request.session['user_id'] = request_env.request.context[:user_id]
        log(request, 'BEFORE')

        authorize request
        request.index = policy_scope(request) if request.indices?

        log(request, 'AFTER')
        update request_env, request

        @app.call request_env
      end

      def env_from_faraday(request_env)
        uri = URI(request_env[:url])
        {
          'rack.input' => request_env[:body] ? StringIO.new(request_env[:body]) : nil,
          'rack.url_scheme' => uri.scheme,
          'HTTP_HOST' => uri.host,
          'PATH_INFO' => uri.path,
          'QUERY_STRING' => uri.query,
          'REQUEST_METHOD' => request_env[:method].to_s.upcase,
          'REQUEST_PATH' => uri.path,
          'SERVER_PORT' => uri.port
        }.merge(request_env[:request_headers])
      end

      def update(request_env, request)
        # TODO: This feels like too little? Is updating the URL enough?
        request_env.url = URI(request.url)
      end

      def authorize(request)
        Pundit.authorize(request.user, request, request.request_method.downcase + '?')
      end

      def policy_scope(request)
        Pundit.policy_scope(request.user, request)
      end

      def log(request, stage)
        logger.debug '============' + stage.ljust(56) + '============'
        logger.debug '= ' + "Request: #{request.detail}".ljust(76) + ' ='
        logger.debug '= ' + "Endpoint: #{request.endpoint}".ljust(76) + ' ='
        logger.debug '================================================================================'
      end
    end
  end
end

# request phase
# :method - :get, :post, ...
# :url    - URI for the current request; also contains GET parameters
# :body   - POST parameters for :post/:put requests
# :request_headers

# response phase
# :status - HTTP response status code, such as 200
# :body   - the response body
# :response_headers

# frozen_string_literal: true

require 'proxes/request'
require 'proxes/policies/request_policy'
require 'ditty/services/logger'
require 'ditty/helpers/pundit'
require 'ditty/helpers/authentication'

module ProxES
  module Middleware
    class Security
      attr_reader :logger

      def initialize(app, logger = nil)
        @app = app
        @logger = logger || ::Ditty::Services::Logger.instance
      end

      def call(env)
        request = ProxES::Request.from_env(env)
        log(request, 'BEFORE')

        check_basic request
        authorize request
        request.index = policy_scope(request) if request.indices?

        log(request, 'AFTER')

        @app.call env
      end

      def check_basic(request)
        auth = Rack::Auth::Basic::Request.new(request.env)
        return false unless auth.provided? && auth.basic?

        identity = ::Ditty::Identity.find(username: auth.credentials[0])
        identity ||= ::Ditty::Identity.find(username: CGI.unescape(auth.credentials[0]))
        return false unless identity&.authenticate(auth.credentials[1])

        request.env['rack.session'] ||= {}
        request.env['rack.session']['user_id'] = identity.user_id
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

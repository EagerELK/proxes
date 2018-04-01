# frozen_string_literal: true

require 'proxes/request'
require 'proxes/policies/request_policy'
require 'ditty/services/logger'
require 'ditty/helpers/pundit'
require 'ditty/helpers/authentication'

module ProxES
  module Middleware
    class Security
      attr_reader :env, :logger

      include Ditty::Helpers::Authentication
      include Ditty::Helpers::Pundit
      include Ditty::Helpers::Wisper

      def initialize(app, logger = nil)
        @app = app
        @logger = logger || ::Ditty::Services::Logger.instance
      end

      def call(env)
        @env = env
        request = ProxES::Request.from_env(env)
        log(request, 'BEFORE')

        check_basic request
        authorize request, request.request_method.downcase

        request.index = policy_scope(request) if request.indices?
        log(request, 'AFTER')

        @app.call env
      end

      def log(request, stage)
        logger.debug '============' + stage.ljust(56) + '============'
        logger.debug '= ' + "Request: #{request.request_method} #{request.fullpath} (#{request.class.name})".ljust(76) + ' ='
        logger.debug '= ' + "Endpoint: #{request.endpoint}".ljust(76) + ' ='
        logger.debug '================================================================================'
      end
    end
  end
end

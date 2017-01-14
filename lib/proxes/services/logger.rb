# frozen_string_literal: true
require 'logger'
require 'yaml'
require 'singleton'
require 'active_support/inflector'
require 'proxes/loggers/elasticsearch'

# ProxES::Services::Logger.instance

module ProxES
  module Services
    class Logger
      include Singleton
      attr_reader :loggers

      def initialize
        @loggers = []
        config.each do |values|
          klass = values['class'].constantize
          opts = values['options'] || nil
          logger = klass.new(opts)
          if values['level']
            level = values['level'].to_sym
            logger.level = klass.const_get(level)
          end
          @loggers << logger
        end
      end

      private

      def config
        YAML.load_file('./config/logger.yml')
      end
    end
  end
end

# frozen_string_literal: true
module ProxES
  module Loggers
    class Elasticsearch
      attr_accessor :level, :url, :log

      WARN = 2

      def initialize(args)
        @level = args['level'] || 0
        @url = args['url'] || ''
        @log = args['log'] || false
      end
    end
  end
end

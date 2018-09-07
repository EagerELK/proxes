# frozen_string_literal: true

require 'proxes/request'
require 'proxes/policies/request/stats_policy'

module ProxES
  class Request
    class Stats < Request
      attr_reader :index

      def index=(idx)
        @index = idx
        self.path_info = '/' + [index, endpoint].compact
                                                .map { |v| v.is_a?(Array) ? v.join(',') : v }
                                                .select { |v| !v.nil? && v != '' }.join('/')
      end

      def endpoint
        '_stats'
      end

      def parse
        @index ||= check_part(path_parts[0])
      end

      def stats
        @stats ||= check_part(path_parts[2])
      end

      def indices?
        true
      end

      def indices
        @index || []
      end
    end
  end
end

# frozen_string_literal: true

require 'proxes/request'
require 'proxes/policies/request/mapping_policy'

module ProxES
  class Request
    class Mapping < Request
      attr_reader :index, :type

      def endpoint
        '_mapping'
      end

      def indices?
        true
      end

      def parse
        parts = path_parts
        if parts[0] == endpoint
          parts.unshift('_all')
        end
        @index ||= check_part(path_parts[0])
        @type  ||= check_part(path_parts[2])
      end

      def index=(idx)
        @index = idx
        self.path_info = '/' + [index, endpoint, type].compact
                                                      .map { |v| v.is_a?(Array) ? v.join(',') : v }
                                                      .select { |v| !v.nil? && v != '' }.join('/')
      end

      def indices
        @index
      end
    end
  end
end

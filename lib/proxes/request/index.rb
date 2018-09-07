# frozen_string_literal: true

require 'proxes/request'
require 'proxes/policies/request/index_policy'

module ProxES
  class Request
    class Index < Request
      attr_reader :index, :type, :id

      def index=(idx)
        @index = idx
        self.path_info = '/' + [index, type, id].compact
                                                .map { |v| v.is_a?(Array) ? v.join(',') : v }
                                                .select { |v| !v.nil? && v != '' }.join('/')
      end

      def endpoint
        nil
      end

      def parse
        @index ||= check_part(path_parts[0])
        @type ||= check_part(path_parts[1])
        @id ||= check_part(path_parts[2])
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

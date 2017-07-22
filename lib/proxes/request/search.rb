# frozen_string_literal: true

require 'proxes/request'
require 'proxes/policies/request/search_policy'

module ProxES
  class Request
    class Search < Request
      attr_reader :index, :type

      def index=(idx)
        @index = idx
        self.path_info = '/' + [index, type, id, endpoint].compact
                                                          .map { |v| v.is_a?(Array) ? v.join(',') : v }
                                                          .select { |v| !v.nil? && v != '' }.join('/')
      end

      def endpoint
        '_search'
      end

      def parse
        @index ||= check_part(path_parts[0]) unless path_parts[0] == endpoint
        @type  ||= check_part(path_parts[1]) unless path_parts[1] == endpoint
        @id    ||= check_part(path_parts[2]) unless path_parts[2] == endpoint
      end

      def id
        @id == [] ? nil : @id
      end

      def indices?
        type != ['scroll']
      end
    end
  end
end

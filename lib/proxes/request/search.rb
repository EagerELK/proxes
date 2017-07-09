# frozen_string_literal: true

require 'rack'
require 'proxes/request'

module ProxES
  class Request
    class Search < Request
      attr_reader :index, :type

      def index=(idx)
        @index = idx
        self.path_info = '/' + [index, type, id, endpoint]
                         .map { |v| v.is_a?(Array) ? v.join(',') : v }
                         .select { |v| !v.nil? && v != '' }.join('/')
      end

      def endpoint
        '_search'
      end

      def parse
        @index ||= check_part(path_parts[0])
        @type  ||= check_part(path_parts[1])
        @id    ||= check_part(path_parts[2])
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

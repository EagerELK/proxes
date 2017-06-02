# frozen_string_literal: true

require 'rack'
require 'proxes/request'

module ProxES
  class Request
    class Cat < Request
      attr_reader :index, :type, :id

      def index=(idx)
        @index = idx
        self.path_info = '/' + [endpoint, type, index]
                         .map { |v| v.is_a?(Array) ? v.join(',') : v }
                         .select { |v| !v.nil? && v != '' }.join('/')
      end

      def endpoint
        '_cat'
      end

      def parse
        @type  ||= check_part(path_parts[1])
        @index ||= check_part(path_parts[2])
      end

      def indices?
        true
      end
    end
  end
end

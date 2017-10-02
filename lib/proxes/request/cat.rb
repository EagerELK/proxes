# frozen_string_literal: true

require 'proxes/request'
require 'proxes/policies/request/cat_policy'

module ProxES
  class Request
    class Cat < Request
      attr_reader :index, :type

      def index=(idx)
        @index = idx
        self.path_info = '/' + [endpoint, type, index].compact
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

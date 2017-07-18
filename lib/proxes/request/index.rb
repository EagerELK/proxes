# frozen_string_literal: true

require 'rack'
require 'proxes/request'

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

      def parse
        @index ||= check_part(path_parts[0])
        p @index
        @type ||= check_part(path_parts[1])
        @id ||= check_part(path_parts[2])
      end

      def indices?
        true
      end
    end
  end
end

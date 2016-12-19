require 'rack'
require 'proxes/request/base'

module ProxES
  class Request
    class Search < Base
      attr_accessor :index
      attr_reader :type

      def parse
        @index ||= check_part(path_parts[0])
        @type  ||= check_part(path_parts[1])
        @id    ||= check_part(path_parts[2])
      end

      def id
        @id == [] ? nil : @id
      end

      def has_indices?
        true
      end
    end
  end
end

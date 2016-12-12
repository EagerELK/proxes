require 'rack'

module ProxES
  class Request
    class Snapshot < Base
      attr_reader :repository

      def parse
        @repository ||= check_part(path_parts[1])
        @repository = [] if repository.nil?
      end

      def has_indices?
        false
      end
    end
  end
end

require 'rack'
require 'proxes/request/base'

module ProxES
  class Request
    class Cluster < Base
      def has_indices?
        false
      end

      def parse
      end
    end
  end
end

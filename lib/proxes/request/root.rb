require 'rack'
require 'proxes/request/base'

module ProxES
  class Request
    class Root < Base
      def has_indices?
        false
      end

      def parse
      end
    end
  end
end

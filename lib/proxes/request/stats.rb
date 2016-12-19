require 'rack'
require 'proxes/request/base'

module ProxES
  class Request
    class Stats < Base
      def has_indices?
        true
      end

      def parse
      end
    end
  end
end

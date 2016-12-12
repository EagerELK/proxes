require 'rack'

module ProxES
  class Request
    class Stats < Base
      def has_indices?
        true
      end
    end
  end
end

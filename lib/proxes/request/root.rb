# frozen_string_literal: true
require 'rack'
require 'proxes/request/base'

module ProxES
  class Request
    class Root < Base
      def indices?
        false
      end

      def parse; end
    end
  end
end

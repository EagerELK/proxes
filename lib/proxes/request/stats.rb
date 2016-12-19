# frozen_string_literal: true
require 'rack'
require 'proxes/request/base'

module ProxES
  class Request
    class Stats < Base
      def indices?
        true
      end

      def parse; end
    end
  end
end

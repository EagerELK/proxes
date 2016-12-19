# frozen_string_literal: true
require 'rack'
require 'proxes/request/base'

module ProxES
  class Request
    class Cluster < Base
      def indices?
        false
      end

      def parse; end
    end
  end
end

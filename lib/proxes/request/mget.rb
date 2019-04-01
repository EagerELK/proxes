# frozen_string_literal: true

require 'proxes/request/multi'
require 'proxes/policies/request/mget_policy'

module ProxES
  class Request
    class Mget < Multi
      INDICES_REGEX = /"(_index)"\s*:\s*"(.*?)"/.freeze

      attr_reader :index, :type

      def endpoint
        '_mget'
      end

      class << self
        def indices_regex
          INDICES_REGEX
        end
      end
    end
  end
end

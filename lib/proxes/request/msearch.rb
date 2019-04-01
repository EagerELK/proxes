# frozen_string_literal: true

require 'proxes/request/multi'
require 'proxes/policies/request/msearch_policy'

module ProxES
  class Request
    class Msearch < Multi
      INDICES_REGEX = /"(index)"\s*:\s*"(.*?)"/.freeze

      attr_reader :index, :type

      def endpoint
        '_msearch'
      end

      class << self
        def indices_regex
          INDICES_REGEX
        end
      end
    end
  end
end

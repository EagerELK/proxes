# frozen_string_literal: true

require 'proxes/request/multi'
require 'proxes/policies/request/bulk_policy'

module ProxES
  class Request
    class Bulk < Multi
      INDICES_REGEX = /"(index|delete|create|update)".*"_index"\s*:\s*"(.*?)"/.freeze

      attr_reader :index, :type

      def endpoint
        '_bulk'
      end

      class << self
        def indices_regex
          INDICES_REGEX
        end
      end
    end
  end
end

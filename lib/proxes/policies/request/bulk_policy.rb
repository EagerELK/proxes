# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'proxes/policies/request_policy'

module ProxES
  class Request
    class BulkPolicy < RequestPolicy
      def post?
        return false if super == false || (request.bulk_indices == '' || patterns.blank?)

        # Check if each index has a pattern that matches
        request.indices.find do |idx|
          patterns.find { |idx_pattern| idx =~ /#{idx_pattern}/ }.nil?
        end.nil?
      end

      class Scope < RequestPolicy::Scope
      end
    end
  end
end

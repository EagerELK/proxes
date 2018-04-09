# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'proxes/policies/request_policy'

module ProxES
  class Request
    class BulkPolicy < RequestPolicy
      def post?
        return false if user.nil? ||
                        (request.index && !index_allowed?) ||
                        (request.bulk_indices == '' || patterns.blank?)

        patterns.find do |pattern|
          request.bulk_indices.find { |idx| idx !~ /#{pattern}/ }
        end.nil?
      end

      class Scope < RequestPolicy::Scope
      end
    end
  end
end

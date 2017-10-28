# frozen_string_literal: true

require 'proxes/policies/request_policy'

module ProxES
  class Request
    class SnapshotPolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
        def resolve
          request
        end
      end
    end
  end
end

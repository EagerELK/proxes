# frozen_string_literal: true

require 'proxes/policies/request_policy'

module ProxES
  class Request
    class CreatePolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
        def resolve
          super.count > 0 ? request.index : []
        end
      end
    end
  end
end

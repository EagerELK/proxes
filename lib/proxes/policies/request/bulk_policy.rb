# frozen_string_literal: true

require 'proxes/policies/request_policy'

module ProxES
  class Request
    class BulkPolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
      end
    end
  end
end

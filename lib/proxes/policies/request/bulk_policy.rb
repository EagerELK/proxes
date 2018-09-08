# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'proxes/policies/request_policy'

module ProxES
  class Request
    class BulkPolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
      end
    end
  end
end

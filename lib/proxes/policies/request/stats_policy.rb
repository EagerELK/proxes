# frozen_string_literal: true

require 'proxes/policies/request_policy'

module ProxES
  class Request
    class StatsPolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
      end
    end
  end
end

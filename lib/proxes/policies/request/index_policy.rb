# frozen_string_literal: true

require 'ditty/db'
require 'proxes/models/permission'
require 'proxes/policies/request_policy'

module ProxES
  class Request
    class IndexPolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
      end
    end
  end
end

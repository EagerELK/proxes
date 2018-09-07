# frozen_string_literal: true

require 'ditty/db'
require 'proxes/models/permission'
require 'proxes/policies/request_policy'

module ProxES
  class Request
    class IndexPolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
        def resolve
          result = super
          return [] unless result.count > 0
          %w[POST PUT].include?(request.request_method) ? request.indices : result
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'ditty/db'
require 'proxes/models/permission'
require 'proxes/policies/request_policy'

module ProxES
  class Request
    class IndexPolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
        def resolve
          return [] if user.nil?
          patterns = Permission.for_user(user, 'INDEX').map do |permission|
            permission.pattern.gsub(/\{user.(.*)\}/) do |_match|
              user.send(Regexp.last_match[1].to_sym)
            end
          end
          result = filter(request.index, patterns)
          return [] unless result.count > 0
          %w[POST PUT].include?(request.request_method) ? request.index : result
        end
      end
    end
  end
end

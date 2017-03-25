# frozen_string_literal: true
module ProxES
  class Request
    class SearchPolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
        def resolve
          patterns = Permission.where(verb: 'INDEX', role: user.roles).map do |permission|
            permission.pattern.gsub(/\{user.(.*)\}/) { |match| user.send(Regexp.last_match[1].to_sym) }
          end
          filter scope.index, patterns
        end
      end
    end
  end
end

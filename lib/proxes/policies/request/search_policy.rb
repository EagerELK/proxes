# frozen_string_literal: true

module ProxES
  class Request
    class SearchPolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
        def resolve
          return false if user.nil?

          patterns = Permission.for_user(user, 'INDEX').map do |permission|
            permission.pattern.gsub(/\{user.(.*)\}/) { |_match| user.send(Regexp.last_match[1].to_sym) }
          end
          filter scope.index, patterns
        end
      end
    end
  end
end

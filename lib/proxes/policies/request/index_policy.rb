# frozen_string_literal: true

module ProxES
  class Request
    class IndexPolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
        def resolve
          return [] if user.nil?

          patterns = Permission.for_user(user, 'INDEX').map do |permission|
            permission.pattern.gsub(/\{user.(.*)\}/) { |_match| user.send(Regexp.last_match[1].to_sym) }
          end
          result = filter(scope.index, patterns)
          return [] unless result.count > 0
          ['POST', 'PUT'].include?(scope.request_method) ? scope.index : result
        end
      end
    end
  end
end

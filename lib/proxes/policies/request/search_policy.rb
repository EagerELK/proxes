# frozen_string_literal: true
module ProxES
  class Request
    class SearchPolicy < ProxES::RequestPolicy
      class Scope < ProxES::RequestPolicy::Scope
        def resolve
          scope.index = scope.index & [user.email]
        end
      end
    end
  end
end

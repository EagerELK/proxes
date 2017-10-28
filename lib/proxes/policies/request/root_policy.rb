# frozen_string_literal: true

module ProxES
  class Request
    class RootPolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
        def resolve
          request
        end
      end
    end
  end
end

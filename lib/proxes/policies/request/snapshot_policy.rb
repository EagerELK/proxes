# frozen_string_literal: true
module ProxES
  class Request
    class SnapshotPolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
        def resolve
          scope
        end
      end
    end
  end
end

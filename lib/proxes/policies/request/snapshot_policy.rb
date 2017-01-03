# frozen_string_literal: true
module ProxES
  class Request
    class SnapshotPolicy < ProxES::RequestPolicy
      class Scope < ProxES::RequestPolicy::Scope
        def resolve
          scope
        end
      end
    end
  end
end

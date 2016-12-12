module ProxES
  class Request
    class SnapshotPolicy < ProxES::RequestPolicy
      def get?
        user && user.admin?
      end

      class Scope < ProxES::RequestPolicy::Scope
        def resolve
          scope
        end
      end
    end
  end
end

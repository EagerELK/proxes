module ProxES
  class Request
    class ClusterPolicy < ProxES::RequestPolicy
      def get?
        !!user
      end

      def health?
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

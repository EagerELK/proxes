module ProxES
  class Request
    class RootPolicy < ProxES::RequestPolicy
      def get?
        !!user
      end

      class Scope < ProxES::RequestPolicy::Scope
        def resolve
          scope
        end
      end
    end
  end
end

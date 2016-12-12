module ProxES
  class Request
    class SearchPolicy < ProxES::RequestPolicy
      def get?
        (record.index & [user.email]).count.positive?
      end

      class Scope < ProxES::RequestPolicy::Scope
        def resolve
          scope.index = scope.index & [user.email]
        end
      end
    end
  end
end

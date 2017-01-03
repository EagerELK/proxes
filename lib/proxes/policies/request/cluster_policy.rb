# frozen_string_literal: true
module ProxES
  class Request
    class ClusterPolicy < ProxES::RequestPolicy
      def get?
        !user.nil?
      end

      def health?
        user && user.super_admin?
      end

      class Scope < ProxES::RequestPolicy::Scope
        def resolve
          scope
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'ditty/policies/application_policy'

module ProxES
  class PermissionPolicy < Ditty::ApplicationPolicy
    def create?
      user && user.super_admin?
    end

    def list?
      create?
    end

    def read?
      create?
    end

    def update?
      read?
    end

    def delete?
      create?
    end

    def permitted_attributes
      %i[verb pattern index role_id user_id]
    end

    class Scope < Ditty::ApplicationPolicy::Scope
      def resolve
        user && user.super_admin? ? scope : scope.where(id: -1)
      end
    end
  end
end

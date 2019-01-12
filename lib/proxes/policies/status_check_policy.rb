# frozen_string_literal: true

require 'ditty/policies/application_policy'

module ProxES
  class StatusCheckPolicy < Ditty::ApplicationPolicy
    def create?
      user && (user.super_admin? || user.admin?)
    end

    def list?
      user && (user.super_admin? || user.admin?)
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
      %i[type name source required_value order]
    end

    class Scope < Ditty::ApplicationPolicy::Scope
      def resolve
        user&.super_admin? ? scope : scope.where(id: -1)
      end
    end
  end
end

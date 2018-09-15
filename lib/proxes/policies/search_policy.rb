# frozen_string_literal: true

require 'ditty/policies/application_policy'

module ProxES
  class SearchPolicy < Ditty::ApplicationPolicy
    def list?
      search?
    end

    def search?
      user
    end

    def fields?
      search?
    end

    def indices?
      search?
    end

    def values?
      search?
    end

    class Scope < Ditty::ApplicationPolicy::Scope
      def resolve
        user && user.super_admin? ? scope : scope.where(id: -1)
      end
    end
  end
end

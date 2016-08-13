require_relative 'application_policy'

module ProxES
  class ESRequestPolicy < ApplicationPolicy
    def _root?
      !!user
    end

    def _cat?
      user && user.admin?
    end

    def _search?
      return false unless user

      return true if user.admin?

      return false unless record.index # Just deny non-specified indices for now

      record.index =~ /#{user.index_prefix}(-.*)?/
    end

    def _index?
      _search?
    end

    def _stats?
      !!user
    end

    def health?
      !!user
    end

    def stats?
      return true if record.endpoint == '_cluster'

      false
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        if scope.index.nil? && !user.admin?
          scope.index = "#{user.index_prefix}"
        end
      end
    end
  end
end

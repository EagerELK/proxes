# frozen_string_literal: true

require 'ditty/policies/application_policy'

module ProxES
  class StatusPolicy < Ditty::ApplicationPolicy
    def check?
      user
    end

    def list?
      check?
    end

    class Scope < Ditty::ApplicationPolicy::Scope
      def resolve
        []
      end
    end
  end
end

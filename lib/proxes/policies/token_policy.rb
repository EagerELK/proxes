# frozen_string_literal: true
require_relative 'application_policy'

module ProxES
  class TokenPolicy < ApplicationPolicy
    def create?
      user.admin?
    end

    def list?
      create?
    end

    def read?
      record.id == user.id || user.admin?
    end

    def update?
      read?
    end

    def delete?
      create?
    end

    def register?
      true
    end

    def permitted_attributes
      attribs = [:email, :name, :surname]
      attribs << :role if user.admin?
      attribs
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        if user.admin?
          scope.all
        else
          []
        end
      end
    end
  end
end

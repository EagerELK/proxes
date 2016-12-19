# frozen_string_literal: true
require 'sequel'

module ProxES
  class UserRole < Sequel::Model
    many_to_one :user

    subset(:admins, role: %w(admin super_admin))

    def validate
      validates_presence [:user_id, :role]
      validates_includes self.class.role_names, :role
    end

    def self.role_names
      %w(super_admin admin user)
    end
  end
end

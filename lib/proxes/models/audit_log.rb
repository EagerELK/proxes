# frozen_string_literal: true
require 'sequel'

module ProxES
  class AuditLog < Sequel::Model
    many_to_one :user

    def validate
      validates_presence [:user_id, :action]
    end
  end
end

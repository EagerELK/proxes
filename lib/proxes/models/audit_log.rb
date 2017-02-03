# frozen_string_literal: true
require 'proxes/models/base'

module ProxES
  class AuditLog < Base
    many_to_one :user

    def validate
      validates_presence [:user_id, :action]
    end
  end
end

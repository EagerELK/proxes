# frozen_string_literal: true

require 'proxes/models/base'

module ProxES
  class AuditLog < Sequel::Model
    include ProxES::Base
    many_to_one :user

    def validate
      validates_presence [:action]
    end
  end
end

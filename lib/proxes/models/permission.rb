# frozen_string_literal: true
require 'proxes/models/base'

module ProxES
  class Permission < Base
    many_to_one :role
    many_to_one :user

    def validate
      validates_presence [:verb, :pattern]
      validates_presence :role_id unless user_id
      validates_presence :user_id unless role_id
      validates_includes self.class.verbs, :verb
    end

    def self.verbs
      ['GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS', 'TRACE', 'INDEX']
    end
  end
end

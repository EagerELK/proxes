# frozen_string_literal: true
require 'sequel'

module ProxES
  class Permission < Sequel::Model
    many_to_one :role

    def validate
      validates_presence [:role_id, :verb, :pattern]
      validates_includes self.class.verbs, :verb
    end

    def self.verbs
      ['GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS', 'TRACE']
    end
  end
end

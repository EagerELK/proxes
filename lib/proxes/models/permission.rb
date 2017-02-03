# frozen_string_literal: true
require 'proxes/models/base'

module ProxES
  class Permission < Base
    many_to_one :role

    def validate
      validates_presence [:role_id, :verb, :pattern]
      validates_includes self.class.verbs, :verb
    end

    def self.verbs
      ['GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS', 'TRACE', 'INDEX']
    end
  end
end

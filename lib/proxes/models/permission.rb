# frozen_string_literal: true

require 'proxes/models/base'

module ProxES
  class Permission < Sequel::Model
    include ::ProxES::Base

    many_to_one :role
    many_to_one :user

    dataset_module do
      def for_user(a_user, action)
        where(verb: action).where { Sequel.|({ role: a_user.roles }, { user_id: a_user.id }) }
      end
    end

    def validate
      validates_presence [:verb, :pattern]
      validates_presence :role_id unless user_id
      validates_presence :user_id unless role_id
      validates_includes self.class.verbs, :verb
    end

    def self.verbs
      %w[GET POST PUT DELETE HEAD OPTIONS TRACE INDEX]
    end
  end
end

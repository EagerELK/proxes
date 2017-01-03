# frozen_string_literal: true
require 'sequel'

module ProxES
  class Role < Sequel::Model
    many_to_many :users
    one_to_many :permissions

    def validate
      validates_presence [:name]
    end
  end
end

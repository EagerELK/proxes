# frozen_string_literal: true

require 'proxes/models/base'

module ProxES
  class Role < Sequel::Model
    include ProxES::Base

    many_to_many :users
    one_to_many :permissions

    def validate
      validates_presence [:name]
      validates_unique [:name]
    end
  end
end

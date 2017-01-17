# frozen_string_literal: true
require 'sequel'

module ProxES
  class AuditLog < Sequel::Model
    one_to_many :users
  end
end

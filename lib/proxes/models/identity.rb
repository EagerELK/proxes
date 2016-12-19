# frozen_string_literal: true
require 'sequel'
require 'omniauth-identity'
require 'active_support'
require 'active_support/core_ext/object/blank'

module ProxES
  class Identity < Sequel::Model
    many_to_one :user

    attr_accessor :password, :password_confirmation

    # OmniAuth Related
    include OmniAuth::Identity::Model

    def self.locate(conditions)
      where(conditions).first
    end

    def authenticate(unencrypted)
      self if ::BCrypt::Password.new(crypted_password) == unencrypted
    end

    def persisted?
      !new? && @destroyed != true
    end

    # Return whatever we want to pass to the omniauth hash here
    def info
      {
        email: username
      }
    end

    # Validation
    def validate
      validates_presence :username
      unless username.blank?
        validates_unique :username
        validates_format(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :username)
      end

      if password_required
        validates_presence :password
        validates_presence :password_confirmation
        validates_min_length 8, :password
      end

      errors.add(:password_confirmation, 'must match password') if !password.blank? && password != password_confirmation
    end

    # Callbacks
    def before_save
      encrypt_password unless password == '' || password.nil?
    end

    private

    def encrypt_password
      self.crypted_password = ::BCrypt::Password.create(password)
    end

    def password_required
      crypted_password.blank? || !password.blank?
    end
  end
end

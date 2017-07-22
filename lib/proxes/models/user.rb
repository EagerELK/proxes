# frozen_string_literal: true

require 'proxes/models/base'
require 'digest/md5'
require 'active_support'
require 'active_support/core_ext/object/blank'

# Why not store this in Elasticsearch?
module ProxES
  class User < Sequel::Model
    include ::ProxES::Base

    one_to_many :identity
    many_to_many :roles
    one_to_many :permissions
    one_to_many :audit_logs

    def role?(check)
      !roles_dataset.first(name: check).nil?
    end

    def method_missing(method_sym, *arguments, &block)
      if method_sym.to_s[-1] == '?'
        role?(method_sym[0..-2])
      else
        super
      end
    end

    def respond_to_missing?(name, _include_private = false)
      name[-1] == '?'
    end

    def gravatar
      hash = Digest::MD5.hexdigest(email.downcase)
      "https://www.gravatar.com/avatar/#{hash}"
    end

    def validate
      validates_presence :email
      return if email.blank?
      validates_unique :email
      validates_format(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :email)
    end

    # Add the basic roles and identity
    def after_create
      check_roles
    end

    def check_roles
      add_role Role.find_or_create(name: 'user') unless role?('user') || role?('anonymous')
      add_role Role.find_or_create(name: 'super_admin') if id == 1 && ENV['RACK_ENV'] != 'test' && !role?('super_admin')
    end

    def index_prefix
      email
    end

    def username
      identity_dataset.first.username
    end
  end
end

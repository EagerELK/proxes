require 'sequel'
require 'bcrypt'
require 'digest/md5'
require 'active_support'
require 'active_support/core_ext/object/blank'

# Why not store this in Elasticsearch?
module ProxES
  class User < Sequel::Model
    one_to_many :identity

    def has_role?(check)
      check.to_sym == role.to_sym
    end

    def method_missing(method_sym, *arguments, &block)
      if method_sym.to_s[-1] == '?'
        has_role?(method_sym[0..-2])
      else
        super
      end
    end

    def gravatar
      hash = Digest::MD5.hexdigest(email.downcase)
      "https://www.gravatar.com/avatar/#{hash}"
    end

    def validate
      validates_presence :email
      validates_unique   :email unless email.blank?
      validates_format   /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :email unless email.blank?

      validates_presence :role
      validates_includes ['super_admin', 'admin', 'owner', 'user'], :role unless role.blank?
    end

    def index_prefix
      email
    end
  end
end

# frozen_string_literal: true

require 'ditty/models/base'
require 'ditty/models/user'
require 'ditty/models/role'
require 'active_support/core_ext/object/blank'

module ProxES
  class Permission < ::Sequel::Model
    include ::Ditty::Base

    many_to_one :role, class: ::Ditty::Role
    many_to_one :user, class: ::Ditty::User

    dataset_module do
      def for_user(usr)
        return where(id: -1) if usr.nil?

        # TODO: Injection of user fields into regex
        # permission.pattern.gsub(/\{user.(.*)\}/) { |_match| user.send(Regexp.last_match[1].to_sym) }
        where { Sequel.|({ role: usr.roles }, { user_id: usr.id }) }
      end

      def for_request(request)
        where(verb: request.request_method).all.select { |perm| perm.pattern_regex.match request.path }
      end
    end

    def validate
      super
      validates_presence %i[verb pattern]
      validates_presence :role_id unless user_id
      validates_presence :user_id unless role_id
      validates_includes self.class.verbs, :verb
    end

    def pattern_regex
      regex pattern
    end

    def index_regex
      regex index
    end

    private

    def regex(str)
      str ||= ''
      return Regexp.new(str) if str.blank? || (str[0] == '|' && str[-1] == '|')

      str = str.gsub(/([^.])\*/, '\1.*')
      str = '.*' if str == '*' # My regex foo is not strong enough to combine the previous line and this one
      Regexp.new '^' + str
    end

    class << self
      def verbs
        %w[GET POST PUT DELETE HEAD OPTIONS TRACE]
      end

      def from_audit_log(audit_log)
        return {} if audit_log.details.nil?

        match = audit_log.details.match(/^(\w)+ (\S+)/)
        return {} if match.nil?

        {
          verb: match[1],
          path: match[2]
        }
      end
    end
  end
end

module Ditty
  class User < ::Sequel::Model
    one_to_many :permissions, class: ::ProxES::Permission
  end
end

module Ditty
  class Role < ::Sequel::Model
    one_to_many :permissions, class: ::ProxES::Permission
  end
end

# frozen_string_literal: true
require 'proxes/db'
require 'proxes/models/permission'
module ProxES
  class RequestPolicy
    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def method_missing(method_sym, *arguments, &block)
      if method_sym.to_s[-1] == '?'
        return false if user.nil?
        # Give me all the user's permissions that match the verb
        ProxES::Permission.where(verb: method_sym[0..-2].upcase, role: user.roles).each do |permission|
          return true if record.path =~ %r{#{permission.pattern}}
        end
        false
      else
        super
      end
    end

    def respond_to_missing?(name, _include_private = false)
      name[-1] == '?'
    end

    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end
    end
  end
end

require 'proxes/policies/request/root_policy'
require 'proxes/policies/request/search_policy'
require 'proxes/policies/request/snapshot_policy'

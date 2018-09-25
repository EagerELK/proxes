# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'ditty/services/logger'
require 'proxes/models/permission'

module ProxES
  class RequestPolicy
    attr_reader :user, :record
    alias request record

    def initialize(user, record)
      @user = user || Ditty::User.anonymous_user
      @record = record
    end

    def method_missing(method_sym, *arguments, &block)
      return super unless respond_to_missing? method_sym

      return true if user && user.super_admin?
      return false if permissions.empty?

      return permissions.count.positive? unless request.indices?

      # Only allow if all the indices match the given permissions
      request.indices.find do |idx|
        permissions.find { |perm| perm.index_regex.match idx }.nil?
      end.nil?
    end

    def respond_to_missing?(name, _include_private = false)
      name[-1] == '?'
    end

    def permissions
      @permissions ||= Permission.for_user(user).for_request(request)
    end

    class Scope
      attr_reader :user, :scope
      alias request scope

      def initialize(user, scope)
        @user = user || Ditty::User.anonymous_user
        @scope = scope
      end

      def resolve
        return permissions.map(&:index) if request.indices == ['*'] ||
                                           request.indices.blank? ||
                                           (user && user.super_admin?)

        request.indices.select do |idx|
          permissions.find { |perm| perm.index_regex.match idx }
        end
      end

      def permissions
        @permissions ||= Permission.for_user(user).for_request(request)
      end
    end
  end
end

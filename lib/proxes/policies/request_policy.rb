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

      return false if permissions.empty?

      return permissions.count.positive? unless request.indices?

      # Only allow if all the indices match the given permissions
      request.indices.find do |idx|
        idx = idx[1..-1] if idx[0] == '-'
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
        return permissions.map(&:index).uniq if request.indices == ['*'] || request.indices == ['_all'] || request.indices.blank?

        request.indices.select do |idx|
          idx = idx[1..-1] if idx[0] == '-'
          permissions.find { |perm| perm.index_regex.match idx }
        end.uniq
      end

      def permissions
        @permissions ||= Permission.for_user(user).for_request(request)
      end
    end
  end
end

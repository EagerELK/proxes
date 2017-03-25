# frozen_string_literal: true
require 'proxes/db'
require 'proxes/models/permission'
require 'proxes/services/logger'
require 'proxes/helpers/indices'

module ProxES
  class RequestPolicy
    include Helpers::Indices

    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def method_missing(method_sym, *arguments, &block)
      if method_sym.to_s[-1] == '?'
        return false if user.nil?

        if record.indices?
          patterns = Permission.where(verb: 'INDEX', role: user.roles).map do |permission|
            permission.pattern.gsub(/\{user.(.*)\}/) { |match| user.send(Regexp.last_match[1].to_sym) }
          end
          return filter(record.index, patterns).count.positive?
        else
          # Give me all the user's permissions that match the verb
          Permission.where(verb: method_sym[0..-2].upcase, role: user.roles).each do |permission|
            return true if record.path =~ %r{#{permission.pattern}}
          end
        end
        false
      else
        super
      end
    end

    def respond_to_missing?(name, _include_private = false)
      name[-1] == '?'
    end

    def logger
      @logger ||= ProxES::Services::Logger.instance
    end

    class Scope
      include Helpers::Indices

      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def logger
        @logger ||= ProxES::Services::Logger.instance
      end
    end
  end
end

require 'proxes/policies/request/root_policy'
require 'proxes/policies/request/stats_policy'
require 'proxes/policies/request/search_policy'
require 'proxes/policies/request/snapshot_policy'

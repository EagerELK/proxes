# frozen_string_literal: true

require 'ditty/db'
require 'proxes/models/permission'
require 'proxes/helpers/indices'
require 'ditty/services/logger'

module ProxES
  class RequestPolicy
    include Helpers::Indices

    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def method_missing(method_sym, *arguments, &block)
      return super if method_sym.to_s[-1] != '?'

      return true if record.indices? && index_allowed?
      action_allowed? method_sym[0..-2].upcase
    end

    def respond_to_missing?(name, _include_private = false)
      name[-1] == '?'
    end

    def index_allowed?
      patterns = patterns_for('INDEX').map do |permission|
        permission.pattern.gsub(/\{user.(.*)\}/) { |_match| user.send(Regexp.last_match[1].to_sym) }
      end
      filter(record.index, patterns).count > 0
    end

    def action_allowed?(action)
      # Give me all the user's permissions that match the verb
      patterns_for(action).each do |permission|
        return true if record.path =~ /#{permission.pattern}/
      end
      false
    end

    def patterns_for(action)
      return Permission.for_user(user, action) if user
      []
    end

    def logger
      @logger ||= Ditty::Services::Logger.instance
    end

    class Scope
      include Helpers::Indices

      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def logger
        @logger ||= Ditty::Services::Logger.instance
      end

      def resolve
        scope
      end
    end
  end
end

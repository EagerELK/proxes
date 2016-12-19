# frozen_string_literal: true
module ProxES
  class RequestPolicy
    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
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
require 'proxes/policies/request/stats_policy'
require 'proxes/policies/request/search_policy'
require 'proxes/policies/request/cluster_policy'
require 'proxes/policies/request/snapshot_policy'

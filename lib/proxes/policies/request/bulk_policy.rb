# frozen_string_literal: true

require 'proxes/policies/request_policy'

module ProxES
  class Request
    class BulkPolicy < RequestPolicy
      def post?
        return false if user.nil?

        patterns = Permission.for_user(user, 'INDEX').map do |permission|
          permission.pattern.gsub(/\{user.(.*)\}/) { |_match| user.send(Regexp.last_match[1].to_sym) }
        end

        return false if request.index && !index_allowed?

        patterns.find do |pattern|
          request.bulk_indices.find { |idx| idx !~ /#{pattern}/}
        end.nil?
      end

      class Scope < RequestPolicy::Scope
        def resolve
          return false if user.nil?

          patterns = Permission.for_user(user, 'INDEX').map do |permission|
            permission.pattern.gsub(/\{user.(.*)\}/) { |_match| user.send(Regexp.last_match[1].to_sym) }
          end
          filter request.index, patterns
        end
      end
    end
  end
end

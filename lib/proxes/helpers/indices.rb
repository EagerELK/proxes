# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'

module ProxES
  module Helpers
    module Indices
      def filter(asked, against)
        return against.map { |a| a.gsub(/\.\*/, '*') } if asked == ['*'] || asked.blank?

        answer = []
        against.each do |pattern|
          answer.concat(asked.select { |idx| idx =~ /#{pattern}/ })
        end
        answer
      end

      def patterns
        current_user = user || Ditty::User.anonymous_user
        return [] if current_user.nil?
        patterns_for('INDEX').map do |permission|
          return nil if permission.pattern.blank?
          permission.pattern.gsub(/\{user.(.*)\}/) { |_match| current_user.send(Regexp.last_match[1].to_sym) }
        end.compact
      end

      def patterns_for(action)
        current_user = user || Ditty::User.anonymous_user
        return [] if current_user.nil?
        Permission.for_user(current_user, action)
      end
    end
  end
end

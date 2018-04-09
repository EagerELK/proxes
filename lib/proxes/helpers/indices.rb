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
    end
  end
end

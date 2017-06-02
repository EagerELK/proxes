# frozen_string_literal: true

module ProxES
  module Helpers
    module Indices
      def filter(asked, against)
        return against.map { |a| a.gsub(/\.\*/, '*') } if asked == ['*'] || asked == [] || asked.nil?

        answer = []
        against.each do |pattern|
          answer.concat(asked.select { |idx| idx =~ /#{pattern}/ })
        end
        answer.count > 0 ? answer : against
      end
    end
  end
end

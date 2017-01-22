# frozen_string_literal: true
module ProxES
  module Helpers
    module Indices
      def filter(asked, against)
        p 'filter'
        p asked
        p against
        return against.map { |a| a.gsub(%r{\.\*}, '*') } if asked == ['*'] || asked == []

        answer = []
        against.each do |pattern|
          answer.concat asked.select { |idx| idx =~ %r{#{pattern}} }
        end
        answer
      end
    end
  end
end

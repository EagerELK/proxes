# frozen_string_literal: true
require 'rack'
require 'proxes/request'

module ProxES
  class Request
    class Stats < ProxES::Request
      attr_reader :index

      def index=(idx)
        @index = idx
        self.path_info = '/' + [ index, type, id, endpoint ]
          .map { |v| v.is_a? Array ? v.join(',') : v }
          .select { |v| !v.nil? && v != '' }.join('/')
      end

      def endpoint
        '_stats'
      end

      def parse
        @index ||= check_part(path_parts[0])
      end

      def indices?
        true
      end
    end
  end
end

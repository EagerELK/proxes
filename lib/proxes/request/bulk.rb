# frozen_string_literal: true

require 'proxes/request'
require 'proxes/policies/request/bulk_policy'

module ProxES
  class Request
    class Bulk < Request
      attr_reader :index, :type

      REGEX = /"(index|delete|create|update)".*"_index"\s*:\s*"(.*?)"/

      def bulk_indices
        @bulk_indices ||= begin
          body.read.scan(REGEX).tap { |_r| body.rewind }
        end.map { |e| e[1] }.uniq
      end

      def index=(idx)
        @bulk_indices = []
        @index = idx
        self.path_info = '/' + [index, type, endpoint].compact
                                                      .map { |v| v.is_a?(Array) ? v.join(',') : v }
                                                      .select { |v| !v.nil? && v != '' }.join('/')
      end

      def endpoint
        '_bulk'
      end

      def parse
        @index ||= check_part(path_parts[0]) unless path_parts[0] == endpoint
        @type  ||= check_part(path_parts[1]) unless path_parts[1] == endpoint
      end

      def indices?
        indices.blank? == false
      end

      def indices
        bulk_indices + (@index || [])
      end
    end
  end
end

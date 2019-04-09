# frozen_string_literal: true

require 'proxes/request'

module ProxES
  class Request
    class Multi < Request
      # Read up on URL-based access control - https://www.elastic.co/guide/en/elasticsearch/reference/current/url-access-control.html
      # Setting `rest.action.multi.allow_explicit_index` to false will not allow the user to send an index in the request body
      # which negates this. Depending on your needs, you can enable / disable this
      def body_indices
        # TODO: Do / Don't do this depending on rest.action.multi.allow_explicit_index
        return [] if body.nil?

        @body_indices ||= begin
          body.read.scan(self.class.indices_regex).tap { body.rewind }
        end.map { |e| e[1] }.compact.uniq
      end

      def index=(idx)
        @body_indices = []
        @index = idx
        self.path_info = '/' + [index, type, endpoint].compact
                                                      .map { |v| v.is_a?(Array) ? v.join(',') : v }
                                                      .select { |v| !v.nil? && v != '' }.join('/')
      end

      def parse
        @index ||= check_part(path_parts[0]) unless path_parts[0] == endpoint
        @type  ||= check_part(path_parts[1]) unless path_parts[1] == endpoint
      end

      def indices?
        indices.blank? == false
      end

      def indices
        body_indices + (@index || [])
      end
    end
  end
end

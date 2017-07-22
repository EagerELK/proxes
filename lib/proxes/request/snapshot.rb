# frozen_string_literal: true

require 'proxes/request'
require 'proxes/policies/request/snapshot_policy'

module ProxES
  class Request
    class Snapshot < Request
      attr_reader :repository

      def parse
        @repository ||= check_part(path_parts[1])
        @repository = [] if repository.nil?
      end
    end
  end
end

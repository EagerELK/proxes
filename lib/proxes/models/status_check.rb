# frozen_string_literal: true

require 'proxes/timed_cache'

module ProxES
  class StatusCheck < Sequel::Model
    plugin :single_table_inheritance, :type

    SOURCE_CALLS = {
      health: %i[cluster health],
      node_stats: %i[nodes stats]
    }.freeze

    def validate
      super
      validates_presence %i[name source]
    end

    def check
      raise 'Unimplemented'
    end

    def value
      raise 'Unimplemented'
    end

    def passed?
      return @result if defined? @result

      check
    end

    def source_result
      self.class.source_result(source)
    end

    def children; end

    def formatted(val = nil)
      val || value
    end

    def policy_class
      StatusCheckPolicy
    end

    class << self
      def search_client=(client)
        @@search_client = client
      end

      def search_client
        @@search_client
      end

      def source_result(source)
        raise 'No search client' unless search_client

        @source_result ||= TimedCache.new do |h, k|
          h[k] = search_client
          SOURCE_CALLS[source.to_sym].each do |call|
            h[k] = h[k].send(call)
          end
          h[k]
        end
      end
    end
  end

  Dir.glob(File.expand_path('./status_checks', __dir__) + '/*.rb').each { |f| require f }
end

# Table: status_checks
# Columns:
#  id             | integer      | PRIMARY KEY AUTOINCREMENT
#  type           | varchar(255) |
#  name           | varchar(255) |
#  source         | varchar(255) |
#  required_value | varchar(255) |
#  order          | integer      | DEFAULT 1
#  created_at     | timestamp    | DEFAULT datetime(CURRENT_TIMESTAMP, 'localtime')
#  updated_at     | timestamp    | DEFAULT datetime(CURRENT_TIMESTAMP, 'localtime')
# Indexes:
#  sqlite_autoindex_status_checks_1 | UNIQUE (name)

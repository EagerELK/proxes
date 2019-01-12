# frozen_string_literal: true

require 'proxes/services/es'

module ProxES
  class StatusCheck < Sequel::Model
    plugin :single_table_inheritance, :type

    extend ProxES::Services::ES

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

    class << self
      def source_result(source)
        @source_result ||= Hash.new do |h, k|
          h[k] = client
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

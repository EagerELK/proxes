# frozen_string_literal: true

require 'elasticsearch'
require 'ditty/services/logger'

module ProxES
  module Services
    module ES
      def client
        @client ||= Elasticsearch::Client.new(
          url: ENV['ELASTICSEARCH_URL'],
          transport_options: {
            ssl: { verify: ENV['SSL_VERIFY_NONE'].to_i != 1 }
          },
          logger: Ditty::Services::Logger.instance
        )
      end

      def cluster_health(level = 'cluster')
        client.cluster.health level: level
      end
    end
  end
end

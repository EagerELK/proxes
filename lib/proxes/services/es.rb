# frozen_string_literal: true

require 'elasticsearch'
require 'ditty/services/logger'

module ProxES
  module Services
    module ES
      def client
        @client ||= Elasticsearch::Client.new(
          url: ENV['ELASTICSEARCH_URL'],
          adapter: :net_http_persistent,
          transport_options: {
            ssl: {
              verify: ENV['SSL_VERIFY_NONE'].to_i != 1,
              cert_store: ssl_store
            }
          },
          logger: Ditty::Services::Logger.instance
        )
      end

      def ssl_store
        store = OpenSSL::X509::Store.new
        store.set_default_paths
        store
      end

      def conn
        client.transport.connections.get_connection.connection
      end

      def cluster_health(level = 'cluster')
        client.cluster.health level: level
      end
    end
  end
end

# frozen_string_literal: true

require 'openssl'
require 'elasticsearch'
require 'ditty/services/logger'

module ProxES
  module Services
    module ES
      def client
        @client ||= Elasticsearch::Client.new(
          url: ENV['ELASTICSEARCH_URL'],
          transport_options: {
            ssl: {
              verify: ENV['SSL_VERIFY_NONE'].to_i != 1,
              cert_store: ssl_store
            }
          },
          log: ENV['APP_ENV'] == 'development',
          logger: Ditty::Services::Logger,
          request_timeout: (ENV['ELASTICSEARCH_REQUEST_TIMEOUT'] || 300).to_i
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
    end
  end
end

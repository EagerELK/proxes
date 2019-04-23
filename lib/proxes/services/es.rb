# frozen_string_literal: true

require 'openssl'
require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'elasticsearch'
require 'ditty/services/logger'
require 'proxes/middleware/faraday'

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
        ) do |faraday|
          faraday.use ProxES::Middleware::Faraday unless ENV['PROXES_PASSTHROUGH']
        end
      end

      def client_with_context(context = {})
        client.tap { |obj| obj.transport.connections.get_connection.connection.options.context = context }
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

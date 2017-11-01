# frozen_string_literal: true

module ProxES
  module Helpers
    module ES
      def client
        @client ||= Elasticsearch::Client.new url: ENV['ELASTICSEARCH_URL']
      end

      def cluster_health(level = 'cluster')
        client.cluster.health level: level
      end
    end
  end
end

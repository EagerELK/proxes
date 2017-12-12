# frozen_string_literal: true

require 'elasticsearch'

module ProxES
  module Services
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

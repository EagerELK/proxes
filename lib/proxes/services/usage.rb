require 'proxes/models/user'
require 'elasticsearch'
require 'json'

module ProxES
  module Services
    class Usage
      class << self
        def cluster(user = nil)
        end

        def node(user = nil)
          result = {}
          stats  = client.nodes.stats metric: 'indices'
          stats['nodes'].each_pair do |name, node_stats|
            result[name] = node_stats['indices']['store']['size_in_bytes']
          end
          result
        end

        def index(user = nil)
        end

        def client
          @@client ||= Elasticsearch::Client.new url: ENV['ELASTICSEARCH_URL']
        end
      end
    end
  end
end

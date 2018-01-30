require 'elasticsearch'
require 'rspec/expectations'

# TODO Properly check merges
# TODO Properly check segments
# TODO Properly check memory size
# TODO Check marvel generated stats if available
module ProxES
  class Check
    include RSpec::Matchers

    def run
      status
      nodes
      shards
    end

    def status
      health = client.cluster.health
      expect(health['status']).to eq('green').or eq('yellow')
    end

    def nodes
      stats = client.nodes.stats

      aggregate_failures 'node check' do
        stats['nodes'].each do |name, node|
          aggregate_failures 'breakers' do
            expect(node['breakers']['fielddata']['tripped'].to_i).to eq(0), "Field Data Breakers Tripping on Node #{name}."
            expect(node['breakers']['parent']['tripped'].to_i).to eq(0), "Parent Breakers Tripping on Node #{name}."
            expect(node['breakers']['request']['tripped'].to_i).to eq(0), "Request Breakers Tripping on Node #{name}."
          end

          aggregate_failures 'filesystem' do
            expect(node['fs']['total']['free_in_bytes'].to_f / node['fs']['total']['total_in_bytes'].to_f * 100.0).to be > 20, "There's not enough disk space left. Node #{name}."
          end

          aggregate_failures 'memory' do
            expect(node['os']['mem']['used_percent']).to be >= 45, "There's more memory available. Considering increasing ES_HEAP_SIZE. Node #{name}."
            expect(node['os']['mem']['used_percent']).to be < 75, "There's not enough memory available. Considering decreasing ES_HEAP_SIZE. Node #{name}.}"

            expect(node['os']['swap']['total_in_bytes']).to be(0), "Swap space is enabled. TURN IT OFF. Node #{name}."
          end

          aggregate_failures 'jvm' do
            expect(node['jvm']['mem']['heap_committed_in_bytes'] / 1024.0 / 1024 / 1024).to be < 31.75, "ES_HEAP_SIZE should not be more than 32GB. Node #{name}."
            expect(node['jvm']['mem']['heap_committed_in_bytes'].to_f / node['os']['mem']['total_in_bytes'].to_f).to be_within(256 * 1024 * 1024).of(50), "ES_HEAP_SIZE should be set to ~= 50% of availalbe memory. Node #{name}."
          end

          # aggregate_failures 'merges' do
          #   expect(TODO)
          # end
        end
      end
    end

    def shards
      shards = client.cat.shards format: 'json', bytes: 'b'
      aggregate_failures 'shard check' do
        shards.each do |shard|
          expect(shard['state']).to eq('STARTED'), "Some shards have not been started. Check again in a couple of minutes. #{shard['index']} #{shard['prirep']}#{shard['shard']}: #{shard['state']}"
          expect(shard['store'].to_i / 1024 / 1024 / 1024).to be <= 50, "Some shards are larger than 50GB, which is not recommended. #{shard['index']} #{shard['prirep']}#{shard['shard']}: #{shard['state']}"
        end
      end
    end

    def client
      @client ||= Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'], log: false)
    end
  end
end

if $0 == __FILE__
  ProxES::Check.new.run
end

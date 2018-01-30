require 'elasticsearch'
require 'rspec'

def client
  @client ||= Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'], log: false)
end

def node_stats
  @node_stats ||= client.nodes.stats
end

describe 'Cluster' do
  context 'Health' do
    it 'is not red' do
      health = client.cluster.health
      expect(health['status']).to eq('green').or eq('yellow')
    end
  end

  context 'Node' do
    node_stats['nodes'].each do |name, node|
      it "#{name} has no tripped breakers" do
        aggregate_failures 'breakers' do
          expect(node['breakers']['fielddata']['tripped'].to_i).to eq(0), 'Field Data Breakers Tripping on Node'
          expect(node['breakers']['parent']['tripped'].to_i).to eq(0), 'Parent Breakers Tripping on Node'
          expect(node['breakers']['request']['tripped'].to_i).to eq(0), 'Request Breakers Tripping on Node'
        end
      end

      it "#{name} has enough disk space" do
        aggregate_failures 'filesystem' do
          expect(node['fs']['total']['free_in_bytes'].to_f / node['fs']['total']['total_in_bytes'].to_f * 100.0).to be > 20, "There's not enough disk space left: #{node['fs']['total']['free_in_bytes']}"
        end
      end

      it "#{name} has the correct memory setup" do
        aggregate_failures 'memory' do
          expect(node['os']['mem']['used_percent']).to be_within(15).of(50), "There's more memory available. Considering increasing ES_HEAP_SIZE: #{node['os']['mem']['used_percent']}%"
          expect(node['os']['mem']['used_percent']).to be < 75, "There's not enough memory available. Considering decreasing ES_HEAP_SIZE: #{node['os']['mem']['used_percent']}%"

          expect(node['os']['swap']['total_in_bytes']).to be(0), 'Swap space is enabled. TURN IT OFF'
        end
      end

      it "#{name} has the correct JVM setup" do
        aggregate_failures 'jvm' do
          expect(node['jvm']['mem']['heap_committed_in_bytes'] / 1024.0 / 1024 / 1024).to be < 31.75, 'ES_HEAP_SIZE should not be more than 32GB'
          expect(node['jvm']['mem']['heap_committed_in_bytes'].to_f / node['os']['mem']['total_in_bytes'].to_f).to be_within(256 * 1024 * 1024).of(50), 'ES_HEAP_SIZE should be set to ~= 50% of availalbe memory'
        end
      end

        # aggregate_failures 'merges' do
        #   expect(TODO)
        # end
    end
  end

  context 'Shard' do
    shards = client.cat.shards format: 'json', bytes: 'b'
    shards.each do |shard|
      it "#{shard['index']} #{shard['prirep']}#{shard['shard']} has started" do
        expect(shard['state']).to eq('STARTED'), "Shard has not been started: #{shard['state']}"
      end

      it "#{shard['index']} #{shard['prirep']}#{shard['shard']} is smaller than 50GB" do
        expect(shard['store'].to_i / 1024 / 1024 / 1024).to be <= 50, "Some shards are larger than 50GB, which is not recommended. #{shard['index']} #{shard['prirep']}#{shard['shard']}: #{shard['state']}"
      end
    end
  end
end

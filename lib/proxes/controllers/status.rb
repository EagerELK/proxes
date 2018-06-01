# frozen_string_literal: true

require 'ditty/controllers/application'
require 'proxes/policies/status_policy'
require 'proxes/services/es'

module ProxES
  class Status < Ditty::Application
    helpers ProxES::Services::ES

    def find_template(views, name, engine, &block)
      super(views, name, engine, &block) # Root
      super(::Ditty::ProxES.view_folder, name, engine, &block) # This Component
      super(::Ditty::App.view_folder, name, engine, &block) # Ditty
    end

    # This provides a URL that can be polled by a monitoring system. It will return
    # 200 OK if all the checks pass, or 500 if any of the checks fail.
    get '/check' do
      checks = []
      begin
        health = client.cluster.health level: 'cluster'
        checks << { text: 'Cluster Reachable', passed: true, value: health['cluster_name'] }
        checks << { text: 'Cluster Health', passed: health['status'] == 'green', value: health['status'] }

        node_stats = client.nodes.stats

        master_nodes = []
        data_nodes = []
        ingestion_nodes = []
        node_stats['nodes'].each_value do |node|
          if node['roles']
            master_nodes << node['name'] if node['roles'].include? 'master'
            data_nodes << node['name'] if node['roles'].include? 'data'
            ingestion_nodes << node['name'] if node['roles'].include? 'ingest'
          elsif node['attributes']
            master_nodes << node['name'] unless node['attributes']['master'] == 'false'
            data_nodes << node['name'] unless node['attributes']['data'] == 'false'
            ingestion_nodes << node['name'] unless node['attributes']['ingest'] == 'false'
          elsif node['settings']
            master_nodes << node['name'] unless node['settings']['node']['master'] == 'false'
            data_nodes << node['name'] unless node['settings']['node']['data'] == 'false'
            ingestion_nodes << node['name'] unless node['settings']['node']['ingest'] == 'false'
          end
        end
        checks << {
          text: 'Master Nodes',
          passed: master_nodes.count > 0,
          value: master_nodes.count > 0 ? master_nodes.sort : 'None'
        }
        checks << {
          text: 'Data Nodes',
          passed: data_nodes.count > 0,
          value: data_nodes.count > 0 ? data_nodes.sort : 'None'
        }
        checks << {
          text: 'Ingestion Nodes',
          passed: true,
          value: ingestion_nodes.count > 0 ? ingestion_nodes.sort : 'None'
        }

        jvm_values = []
        jvm_passed = true
        node_stats['nodes'].each_value do |node|
          jvm_values << "#{node['name']}: #{node['jvm']['mem']['heap_used_percent']}%"
          jvm_passed = false if node['jvm']['mem']['heap_used_percent'] > 85
        end
        checks << { text: 'Node JVM Heap', passed: jvm_passed, value: jvm_values.sort }

        fs_values = []
        fs_passed = true
        node_stats['nodes'].each_value do |node|
          next if node['attributes'] && node['attributes']['data'] == 'false'
          next if node['roles'] && node['roles'].include?('data') == false
          stats = node['fs']['total']
          left = stats['available_in_bytes'] / stats['total_in_bytes'].to_f * 100
          fs_values << "#{node['name']}: #{format('%.02f', left)}% Free"
          fs_passed = false if left < 10
        end
        checks << { text: 'Node File Systems', passed: fs_passed, value: fs_values.sort }

        cpu_values = []
        cpu_passed = true
        node_stats['nodes'].each_value do |node|
          value = (node['os']['cpu_percent'] || node['os']['cpu']['percent'])
          cpu_values << "#{node['name']}: #{value}"
          cpu_passed = false if value.to_i > 70
        end
        checks << { text: 'Node CPU Usage', passed: cpu_passed, value: cpu_values.sort }

        memory_values = []
        memory_sum = 0
        node_stats['nodes'].each_value do |node|
          memory_sum += node['os']['mem']['used_percent']
          memory_values << "#{node['name']}: #{node['os']['mem']['used_percent']}"
        end
        memory_passed = (memory_sum / memory_values.size).to_i < 100
        checks << { text: 'Node Memory Usage', passed: memory_passed, value: memory_values.sort }
      rescue Faraday::Error => e
        checks << { text: 'Cluster Reachable', passed: false, value: e.message }
      end

      status checks.find { |c| c[:passed] == false } ? 500 : 200

      respond_to do |format|
        format.html do
          haml :'status/check', locals: { title: 'Status Check', checks: checks }
        end
        format.json do
          json checks
        end
      end
    end
  end
end

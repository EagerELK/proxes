# frozen_string_literal: true

require 'ditty/controllers/component'
require 'proxes/policies/status_policy'
require 'proxes/helpers/es'
require 'pp'

module ProxES
  class Status < Ditty::Component
    helpers ProxES::Helpers::ES

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
        health = cluster_health
        checks << { text: 'Cluster Reachable', passed: true, value: health['cluster_name'] }
        checks << { text: 'Cluster Health', passed: health['status'] == 'green', value: health['status'] }
      rescue StandardError
        checks << { text: 'Cluster Reachable', passed: false}
      end

      node_stats = client.nodes.stats metric: 'os,fs,jvm'

      jvm_values = []
      jvm_passed = true
      node_stats['nodes'].each do |name, node|
        jvm_values << "#{name}: #{node['jvm']['mem']['heap_used_percent']}%"
        jvm_passed = false if node['jvm']['mem']['heap_used_percent'] > 85
      end
      checks << { text: 'Node JVM Heap', passed: jvm_passed, value: jvm_values }

      fs_values = []
      fs_passed = true
      node_stats['nodes'].each do |name, node|
        stats = node['fs']['total']
        left = stats['available_in_bytes'] / stats['total_in_bytes'].to_f * 100
        fs_values << "#{name}: #{'%.02f' % left}% Free"
        fs_passed = false if left < 10
      end
      checks << { text: 'Node File Systems', passed: fs_passed, value: fs_values }

      cpu_values = []
      cpu_passed = true
      node_stats['nodes'].each do |name, node|
        cpu_values << "#{name}: #{node['os']['cpu']['percent']}"
        cpu_passed = false if node['os']['cpu']['percent'].to_i > 70
      end
      checks << { text: 'Node CPU Usage', passed: cpu_passed, value: cpu_values }

      memory_values = []
      memory_passed = true
      node_stats['nodes'].each do |name, node|
        memory_values << "#{name}: #{node['os']['mem']['used_percent']}"
        memory_passed = false if node['os']['mem']['used_percent'].to_i >= 100
      end
      checks << { text: 'Node Memory Usage', passed: memory_passed, value: memory_values }

      status checks.find { |c| c[:passed] == false } ? 500 : 200
      haml :'status/check', locals: { title: 'Status Check', checks: checks }
    end
  end
end

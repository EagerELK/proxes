# frozen_string_literal: true

module ProxES
  class CPUStatusCheck < StatusCheck
    def value
      node_values.sort.map { |k, v| "#{k}: #{v}%" }
    end

    def node_values
      @node_values ||= source_result['nodes']['nodes'].values.map do |node|
        value = node['os']['cpu_percent'] || node['os']['cpu']['percent']
        [
          node['name'],
          value
        ]
      end.to_h
    end

    def check
      !(node_values.select { |k, v| v > required_value.to_i }).count.positive?
    end
  end
end

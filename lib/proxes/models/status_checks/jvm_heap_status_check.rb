# frozen_string_literal: true

module ProxES
  class JVMHeapStatusCheck < StatusCheck
    def value
      node_values.sort.map { |k, v| "#{k}: #{v}%" }
    end

    def node_values
      @node_values ||= source_result['nodes']['nodes'].values.map do |node|
        [
          node['name'],
          node['jvm']['mem']['heap_used_percent']
        ]
      end.to_h
    end

    def check
      !(node_values.select { |k, v| v >= required_value.to_i }).count.positive?
    end
  end
end

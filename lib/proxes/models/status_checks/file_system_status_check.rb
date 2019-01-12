# frozen_string_literal: true

module ProxES
  class FileSystemStatusCheck < StatusCheck
    def value
      node_values.sort.map { |k, v| "#{k}: #{format('%.02f', v)}% Free" }
    end

    def node_values
      @node_values ||= source_result['nodes']['nodes'].values.map do |node|
        next if node['attributes'] && node['attributes']['data'] == 'false'
        next if node['roles'] && node['roles'].include?('data') == false

        stats = node['fs']['total']
        [
          node['name'],
          stats['available_in_bytes'] / stats['total_in_bytes'].to_f * 100
        ]
      end.compact.to_h
    end

    def check
      !(node_values.select { |k, v| v < required_value.to_f }).count.positive?
    end
  end
end

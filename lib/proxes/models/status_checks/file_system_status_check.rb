# frozen_string_literal: true

module ProxES
  class FileSystemStatusCheck < StatusCheck
    def value
      children.values.min
    end

    def children
      @children ||= source_result['nodes']['nodes'].values.map do |node|
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
      return true if required_value.blank?

      value > required_value.to_f
    end

    def formatted(val = nil)
      format('%.4f%% Minimum Free', val || value)
    end
  end
end

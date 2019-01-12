# frozen_string_literal: true

module ProxES
  class NodesStatusCheck < StatusCheck
    def node_type
      raise 'Unimplemented'
    end

    def check
      return true if required_value.nil?

      required_value.to_i == value.count
    end

    def value
      @value ||= source_result['nodes']['nodes'].map do |_id, node|
        node['name'] if check_node(node)
      end.compact
    end

    def check_node(node)
      node['roles']&.include?(node_type) ||
        node.dig('attributes', node_type) != 'false' ||
        node.dig('settings', 'node', node_type) != 'false'
    end
  end

  class MasterNodesStatusCheck < NodesStatusCheck
    def node_type
      'master'
    end
  end

  class DataNodesStatusCheck < NodesStatusCheck
    def node_type
      'data'
    end
  end

  class IngestNodesStatusCheck < NodesStatusCheck
    def node_type
      'ingest'
    end
  end
end

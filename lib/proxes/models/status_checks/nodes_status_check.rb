# frozen_string_literal: true

module ProxES
  class NodesStatusCheck < StatusCheck
    def node_type
      raise 'Unimplemented'
    end

    def value
      children.count
    end

    def check_node(node)
      node['roles']&.include?(node_type) ||
        node['attributes'] && node.dig('attributes', node_type) != 'false' ||
        node.dig('settings', 'node') && node.dig('settings', 'node', node_type) != 'false'
    end

    def children
      @children ||= source_result['nodes']['nodes'].map do |_id, node|
        [node['name'], 1] if check_node(node)
      end.compact.to_h
    end

    def check
      return true if required_value.blank?

      required_value.to_i == value
    end

    def formatted(val = nil)
      (val || value).to_i == 1 ? '1 Node' : "#{val || value} Nodes"
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

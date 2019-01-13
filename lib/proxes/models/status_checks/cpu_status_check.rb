# frozen_string_literal: true

module ProxES
  class CPUStatusCheck < StatusCheck
    def value
      children.values.inject(0.0) { |sum, el| sum + el } / children.count
    end

    def children
      @children ||= source_result['nodes']['nodes'].values.map do |node|
        value = node['os']['cpu_percent'] || node['os']['cpu']['percent']
        [
          node['name'],
          value.to_f
        ]
      end.to_h
    end

    def check
      value < required_value.to_f
    end

    def formatted(val = nil)
      format('%.4f%% Average Usage', val || value)
    end
  end
end

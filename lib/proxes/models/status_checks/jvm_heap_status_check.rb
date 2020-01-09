# frozen_string_literal: true

module ProxES
  class JVMHeapStatusCheck < StatusCheck
    def value
      children.values.inject(0.0) { |sum, el| sum + el } / children.count
    end

    def children
      @children ||= source_result['nodes'].values.map do |node|
        [
          node['name'],
          node['jvm']['mem']['heap_used_percent'].to_f
        ]
      end.to_h
    end

    def check
      return true if required_value.blank?

      value < required_value.to_f
    end

    def formatted(val = nil)
      format('%.4f%% Average Usage', val || value)
    end
  end
end

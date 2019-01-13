# frozen_string_literal: true

module ProxES
  class ClusterHealthStatusCheck < StatusCheck
    def value
      source_result['status']['status']
    end

    def check
      value == required_value
    end

    def formatted(val = nil)
      (val || value).titlecase
    end
  end
end

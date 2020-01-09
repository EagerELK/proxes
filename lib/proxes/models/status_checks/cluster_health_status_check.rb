# frozen_string_literal: true

module ProxES
  class ClusterHealthStatusCheck < StatusCheck
    def value
      source_result['status']
    end

    def check
      return true if required_value.blank?

      value == required_value
    end

    def formatted(val = nil)
      (val || value).titlecase
    end
  end
end

# frozen_string_literal: true

module ProxES
  class ClusterHealthStatusCheck < StatusCheck
    def value
      source_result['status']['status']
    end

    def check
      value == 'green'
    end
  end
end

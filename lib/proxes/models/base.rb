require 'sequel'

module ProxES
  module Base
    def for_json
      values
    end
  end
end

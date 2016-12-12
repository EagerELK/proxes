require 'rack'

module ProxES
  class Request
    def self.from_env(env)
      request = Rack::Request.new(env)
      splits = request.path.split('/')
      if splits[1] && splits[1][0] == '_'
        endpoint = splits[1][1..-1].titlecase
      else
        endpoint = splits.count.positive? ? splits[-1][1..-1].titlecase : 'Root'
      end
      klass = "ProxES::Request::#{endpoint}"
      const_get(klass).new(env)
    end
  end
end

require 'proxes/request/base'
require 'proxes/request/root'
require 'proxes/request/stats'
require 'proxes/request/search'
require 'proxes/request/snapshot'

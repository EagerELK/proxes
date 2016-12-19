require 'rack'
require 'proxes/request'

module ProxES
  class Request
    def self.from_env(env)
      request = Rack::Request.new(env)
      splits = request.path.split('/')
      if splits[1] && splits[1][0] == '_'
        endpoint = splits[1][1..-1].titlecase
      else
        endpoint = splits.count > 0 ? splits[-1][1..-1].titlecase : 'Root'
      end
      require 'proxes/request/' + endpoint.downcase
      ProxES::Request.const_get(endpoint).new(env)
    end
  end
end

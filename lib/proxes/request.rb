# frozen_string_literal: true
require 'rack'
require 'proxes/request'

module ProxES
  class Request
    def self.from_env(env)
      request = Rack::Request.new(env)
      splits = request.path.split('/')
      endpoint = if splits[1] && splits[1][0] == '_'
                   splits[1][1..-1].titlecase
                 else
                   splits.count > 0 ? splits[-1][1..-1].titlecase : 'Root'
                 end
      require 'proxes/request/' + endpoint.downcase
      ProxES::Request.const_get(endpoint).new(env)
    end
  end
end

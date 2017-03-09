# frozen_string_literal: true
require 'rack'

module ProxES
  class Request < Rack::Request
    def self.from_env(env)
      request = Rack::Request.new(env)
      splits = request.path.split('/')
      endpoint = if splits[1] && splits[1][0] == '_'
                   splits[1][1..-1].titlecase
                 else
                   splits.count > 0 ? splits[-1][1..-1].titlecase : 'Root'
                 end
      begin
        require 'proxes/request/' + endpoint.downcase
        Request.const_get(endpoint).new(env)
      rescue LoadError
        self.new(env)
      end
    end

    def initialize(env)
      super
      parse
    end

    def endpoint
      path_parts[0]
    end

    def parse
      path_parts
    end

    def indices?
      false
    end

    private

    def path_parts
      @path_parts ||= path[1..-1].split('/')
    end

    def check_part(val)
      return val if val.nil?
      return [] if [endpoint, '_all'].include? val
      val.split(',')
    end
  end
end

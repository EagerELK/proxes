# frozen_string_literal: true

require 'rack'

module ProxES
  class Request < Rack::Request
    ID_ENDPOINTS = %w[_create _explain _mlt _percolate _source _termvector _update]

    def self.from_env(env)
      endpoint = path_endpoint(env['REQUEST_PATH'])[1..-1]
      begin
        require 'proxes/request/' + endpoint.downcase
        Request.const_get(endpoint.titlecase).new(env)
      rescue LoadError
        new(env)
      end
    end

    def self.path_endpoint(path)
      path_parts = path[1..-1].split('/')
      return 'root' if path_parts.length == 0
      return path_parts[-1] if ID_ENDPOINTS.include? path_parts[-1]
      return path_parts[-2] if path_parts[-1] == 'count' && path_parts[-2] == '_percolate'
      return path_parts[-2] if path_parts[-1] == 'scroll' && path_parts[-2] == '_search'
      path_parts[0]
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

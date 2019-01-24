# frozen_string_literal: true

require 'rack'

module ProxES
  class Request < Rack::Request
    ID_ENDPOINTS = %w[_create _explain _mlt _percolate _source _termvector _update].freeze
    WRITE_METHODS = %w[POST PUT DELETE].freeze

    def initialize(env)
      @started = Time.now.to_f
      super
      parse
    end

    def endpoint
      path_parts[0]
    end

    def parse
      path_parts
    end

    # Indicate whether or not the request is index specific
    def indices?
      false
    end

    # Return the indices associated with the request as an array. [] if `#indices?` is false
    def indices
      []
    end

    def html?
      get_header('HTTP_ACCEPT')&.include?('text/html')
    end

    def duration
      Time.now.to_f - @started
    end

    def user_id
      return env['rack.session']['user_id'] if env['rack.session']

      env['omniauth.auth']&.uid
    end

    def user
      return nil if user_id.nil?

      @user ||= Ditty::User[user_id]
    end

    def detail
      detail = "#{request_method.upcase} #{fullpath} (#{self.class.name})"
      return detail unless indices?

      "#{detail} #{indices.join(',')}"
    end

    private

    def path_parts
      @path_parts ||= path.split('?')[0][1..-1].split('/')
    end

    def check_part(val)
      return val if val.nil?
      return [] if [endpoint, '_all'].include?(val) && !WRITE_METHODS.include?(request_method)

      val.split(',')
    end

    class << self
      def from_env(env)
        endpoint = path_endpoint(env['REQUEST_PATH'])
        endpoint_class = endpoint.nil? ? 'index' : endpoint[1..-1]
        begin
          require 'proxes/request/' + endpoint_class.downcase
          Request.const_get(endpoint_class.titlecase).new(env)
        rescue LoadError
          new(env)
        end
      end

      def path_endpoint(path)
        return '_root' if ['', nil, '/'].include? path

        path_parts = path[1..-1].split('/')
        return path_parts[-1] if ID_ENDPOINTS.include? path_parts[-1]
        return path_parts[-2] if path_parts[-1] == 'count' && path_parts[-2] == '_percolate'
        return path_parts[-2] if path_parts[-1] == 'scroll' && path_parts[-2] == '_search'

        path_parts.find { |part| part[0] == '_' && part != '_all' }
      end
    end
  end
end

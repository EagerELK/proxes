require 'net/http'
require 'rack'

module ProxES
  # A lot of code in this comes from Rack::Proxy
  class Forwarder
    attr_reader :backend, :streaming

    def initialize(opts = {})
      @backend = URI(opts[:backend]) if opts[:backend]
    end

    def call(env)
      source_request = Rack::Request.new(env)
      full_path = source_request.fullpath == '' ? URI.parse(env['REQUEST_URI']).request_uri : source_request.fullpath
      target_request = Net::HTTP.const_get(source_request.request_method.capitalize).new(full_path)

      http = Net::HTTP.new(backend.host, backend.port)
      target_response = http.request(target_request)

      headers = (target_response.respond_to?(:headers) && target_response.headers) || self.class.normalize_headers(target_response.to_hash)
      body    = target_response.body || ['']
      body    = [body] unless body.respond_to?(:each)

      # Not sure where this is coming from, but it causes timeouts on the client
      headers.delete('transfer-encoding')

      [target_response.code, headers, body]
    end

    class << self
      def normalize_headers(headers)
        mapped = headers.map do |k, v|
          [k, v.is_a?(Array) ? v.join("\n") : v]
        end
        Rack::Utils::HeaderHash.new Hash[mapped]
      end
    end
  end
end

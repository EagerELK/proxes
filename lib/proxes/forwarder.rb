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
      http = Net::HTTP.new(backend.host, backend.port)
      response = http.request(request_from(env))

      headers = (response.respond_to?(:headers) && response.headers) || self.class.normalize_headers(response.to_hash)
      body    = response.body || ['']
      body    = [body] unless body.respond_to?(:each)

      # Not sure where this is coming from, but it causes timeouts on the client
      headers.delete('transfer-encoding')

      # Ensure that the content length rack middleware kicks in
      headers.delete('content-length')

      [response.code, headers, body]
    end

    def request_from(env)
      source = Rack::Request.new(env)
      full_path = source.fullpath == '' ? URI.parse(env['REQUEST_URI']).request_uri : source.fullpath
      target = Net::HTTP.const_get(source.request_method.capitalize).new(full_path)

      body = body_from(source)
      if body
        target.body = body
        target.content_length = body.length
        target.content_type   = source.content_type if source.content_type
      end
      target
    end

    def body_from(request)
      return nil if request.body.nil? || (Kernel.const_defined?('::Puma::NullIO') && request.body.is_a?(Puma::NullIO))
      request.body.read
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

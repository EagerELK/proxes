require 'proxes/services/es'
require 'net/http/persistent'
require 'singleton'
require 'rack'

module ProxES
  # A lot of code in this comes from Rack::Proxy
  class Forwarder
    include Singleton
    include ProxES::Services::ES

    def call(env)
      forward(env)
    rescue SocketError
      headers = { 'Content-Type' => 'application/json' }
      [500, headers, ['{"error":"Could not connect to Elasticsearch"}']]
    end

    def forward(env)
      source = Rack::Request.new(env)
      response = conn.send(source.request_method.downcase) do |req|
        source_body = body_from(source)
        req.body = source_body if source_body
        req.url source.fullpath == '' ? URI.parse(env['REQUEST_URI']).request_uri : source.fullpath
      end
      mangle response
    end

    def mangle(response)
      headers = (response.respond_to?(:headers) && response.headers) || self.class.normalize_headers(response.to_hash)
      body    = response.body || ['']
      body    = [body] unless body.respond_to?(:each)

      # Not sure where this is coming from, but it causes timeouts on the client
      headers.delete('transfer-encoding')
      # Ensure that the content length rack middleware kicks in
      headers.delete('content-length')

      [response.status, headers, body]
    end

    def body_from(request)
      return nil if request.body.nil? || (Kernel.const_defined?('::Puma::NullIO') && request.body.is_a?(Puma::NullIO))
      request.body.read.tap { |_r| request.body.rewind }
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

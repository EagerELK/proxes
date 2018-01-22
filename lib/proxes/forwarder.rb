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
      request = request_from(env)
      request.basic_auth backend.user, backend.password

      begin
        forward(request)
      rescue SocketError
        headers = { 'Content-Type' => 'application/json' }
        [500, headers, ['{"error":"Could not connect to Elasticsearch"}']]
      end
    end

    def forward(request)
      response = http.request(request)

      headers = (response.respond_to?(:headers) && response.headers) || self.class.normalize_headers(response.to_hash)
      body    = response.body || ['']
      body    = [body] unless body.respond_to?(:each)

      # Not sure where this is coming from, but it causes timeouts on the client
      headers.delete('transfer-encoding')

      # Ensure that the content length rack middleware kicks in
      headers.delete('content-length')

      [response.code, headers, body]
    end

    def http
      @http ||= begin
        http = Net::HTTP.new(backend.host, backend.port)
        http.use_ssl = true if backend.is_a? URI::HTTPS
        if ENV['SSL_VERIFY_NONE'].to_i == 1
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          store = OpenSSL::X509::Store.new
          store.set_default_paths
          http.cert_store = store
        end
        http
      end
    end

    def request_from(env)
      source = Rack::Request.new(env)
      fullpath = source.fullpath == '' ? URI.parse(env['REQUEST_URI']).request_uri : source.fullpath
      target = Net::HTTP.const_get(source.request_method.capitalize).new(fullpath)

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

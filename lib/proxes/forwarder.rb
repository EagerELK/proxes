# frozen_string_literal: true

require 'proxes/services/es'
require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'singleton'
require 'rack'

module ProxES
  # A lot of code in this comes from Rack::Proxy
  class Forwarder
    include Singleton
    include ProxES::Services::ES

    def call(env)
      rewrite_response(
        perform_request(
          Rack::Request.new(
            rewrite_env(env)
          )
        )
      )
    end

    def rewrite_env(env)
      env
    end

    # TODO: Consider moving these methods to the ProxES ES Service to enable reuse
    def perform_request(request)
      request.session['init'] = true # Initialize the session
      conn.send(request.request_method.downcase) do |req|
        body = body_from(request)
        req.body = body if body
        req.options.context = { user_id: request.session[:user_id] }
        req.url request.fullpath == '' ? URI.parse(env['REQUEST_URI']).request_uri : request.fullpath
      end
    end

    def rewrite_response(response)
      headers = (response.respond_to?(:headers) && response.headers) || normalize_headers(response.to_hash)
      body    = response.body || ['']
      body    = [body] unless body.respond_to?(:each)

      # Only keep certain headers.
      # See point 1 on https://www.mnot.net/blog/2011/07/11/what_proxies_must_do
      # TODO: Extend on the above
      headers.delete_if { |k, _v| !header_list.include? k.downcase }

      [response.status, headers, body]
    end

    def header_list
      [
        'date',
        'content-type',
        'cache-control'
      ]
    end

    def body_from(request)
      return if request.body.nil? || request.body.respond_to?(:read) == false

      request.body.read.tap { |_r| request.body.rewind }
    end

    def normalize_headers(headers)
      Rack::Utils::HeaderHash.new(
        headers.map do |k, v|
          [k, v.is_a?(Array) ? v.join("\n") : v]
        end.to_h
      )
    end
  end
end

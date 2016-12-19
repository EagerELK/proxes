# frozen_string_literal: true
require 'warden'
require 'jwt'

module ProxES
  module Strategies
    class JwtToken < Warden::Strategies::Base
      def valid?
        authorization_header.is_a?(String) && (authorization_header =~ /^Basic .*$/i).nil?
      end

      def authenticate!
        token = authorization_header.split(' ').last
        begin
          jwt = JWT.decode(token, File.read('.token_secret'), true, verify_expiration: true)

          user = ProxES::User[email: jwt[0]['sub']]

          user ? success!(user) : fail!('Invalid User')
        rescue JWT::ExpiredSignature
          fail!('Authentication Timeout')
        end
      end

      def store?
        false
      end

      def authorization_header
        env['HTTP_AUTHORIZATION'] \
          || env['X-HTTP_AUTHORIZATION'] \
          || env['X_HTTP_AUTHORIZATION'] \
          || env['REDIRECT_X_HTTP_AUTHORIZATION']
      end
    end
  end
end

::Warden::Strategies.add(:jwt_token, ProxES::Strategies::JwtToken)

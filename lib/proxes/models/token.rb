require 'sequel'
require 'jwt'

module ProxES
  class Token < Sequel::Model
    many_to_one :user

    def validate
      validates_presence :user_id
    end

    def base_token
      timeout = ENV['RACK_ENV'] != 'production' ? 60 * 60 : (60 * 60 * 24 * 7)
      {
        jti: id,
        iss: 'ProxES',
        iat: Time.now.to_i,
        exp: Time.now.to_i + timeout,
        sub: user.id,
      }
    end

    def generated(data = {})
      token = base_token.merge(data)

      encoded = JWT.encode(
        token,
        File.read('.token_secret')
      )
      [token, encoded]
    end
  end
end

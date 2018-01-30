# # frozen_string_literal: true
# require 'proxes/base'

# module ProxES
#   class App < Base
#     plugin :multi_route

#     def generate(data = {})
#       token = base_token.merge(data)

#       encoded = JWT.encode(
#         token,
#         File.read('.token_secret')
#       )
#       [token, encoded]
#     end

#     def base_token
#       timeout = ENV['RACK_ENV'] != 'production' ? 60 * 60 : (60 * 60 * 24 * 7)
#       {
#         exp: Time.now.to_i + timeout,
#         iss: 'ProxES',
#         scopes: %w(_search _index)
#       }
#     end

#     route 'tokens' do |r|
#       r.post do
#         authorize current_user, :update
#         flash[:success] = 'Token generated: ' + generate(sub: current_user.email)[1]
#         r.redirect root_url
#       end
#     end
#   end
# end

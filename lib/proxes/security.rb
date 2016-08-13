require 'proxes/base'
require 'proxes/es_request'
require 'proxes/policies/es_policy'

module ProxES
  # Provide OmniAuth::Identity roots and Pundit checks
  class Security < ProxES::Base
    route do |r|
      # Warden
      r.on '_proxes' do
        r.get 'unauthenticated' do
          r.redirect '/auth/identity'
        end
      end

      # Omniauth Identity paths
      r.on 'auth' do
        r.get 'failure' do
          message = case params['message']
          when 'invalid_credentials'
            'Invalid credentials. Please try again.'
          else
            params['message']
          end

          flash[:warning] = message
          r.redirect '/auth/identity'
        end

        r.on 'identity' do
          identity = Identity.new

          r.delete do
            session.delete('user_id')
            flash[:info] = 'Logged Out'
            redirect '/'
          end

          r.get 'register' do
            view 'security/register', locals: { identity: identity }
          end

          r.post 'callback' do
            user = User.find_or_create(email: env['omniauth.auth']['info']['email']){|u| u.role = 'user' }
            identity = Identity.find(username: user.email)
            user.add_identity identity unless identity.user

            flash[:success] = 'Logged In'
            env['warden'].set_user(user)
            r.redirect root_url
          end

          r.post 'new' do
            authorize Identity, :register
            identity = Identity.new(permitted_attributes(Identity, :register))
            if identity.valid? && identity.save
              flash[:info] = 'Successfully Registered. Please log in'
              r.redirect '/auth/identity'
            else
              flash.now[:warning] = 'Could not complete the registration. Please try again.'
              view 'security/register', locals: { identity: identity }
            end
          end

          r.get do
            view 'security/login'
          end
        end
      end

      # Everything Else
      r.on proc{true} do
        authenticate!

        request = ProxES::ESRequest.new(env)

        unless ENV['RACK_ENV'] == 'production'
          puts '================================================================================'
          puts '= ' + "Request: #{request.fullpath}".ljust(76) + '='
          puts '= ' + "Endpoint: #{request.endpoint}".ljust(76) + '='
          puts '= ' + "Index: #{request.index}".ljust(76) + '='
          puts '= ' + "Type: #{request.type}".ljust(76) + '='
          puts '= ' + "Action: #{request.action}".ljust(76) + '='
          puts '================================================================================'
        end

        if request.has_indices?
          policy_scope request
        else
          authorize request
        end

        unless ENV['RACK_ENV'] == 'production'
          puts '================================================================================'
          puts '= ' + "Request: #{request.fullpath}".ljust(76) + '='
          puts '= ' + "Endpoint: #{request.endpoint}".ljust(76) + '='
          puts '= ' + "Index: #{request.index}".ljust(76) + '='
          puts '= ' + "Type: #{request.type}".ljust(76) + '='
          puts '= ' + "Action: #{request.action}".ljust(76) + '='
          puts '================================================================================'
        end

        # Throw so that we move on to the next middleware
        throw :next, true
      end
    end
  end
end

class Roda
  module RodaPlugins
    # Provide helper methods to access Warden
    module Authentication
      module InstanceMethods

        def current_user
          env['warden'] ? env['warden'].user : nil
        end

        def authenticate
          env['warden'] && env['warden'].authenticate
        end

        def authenticated?
          env['warden'] && env['warden'].authenticated?
        end

        def authenticate!
          raise NotAuthenticated unless env['warden']
          env['warden'].authenticate!
        end

        def logout
          env['warden'] && env['warden'].logout
        end
      end

      class NotAuthenticated < StandardError
      end
    end

    register_plugin(:authentication, Authentication)
  end
end

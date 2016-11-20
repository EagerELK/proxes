module ProxES::Helpers
  module Authentication
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

    def set_user(user)
      env['warden'].set_user(user)
    end
  end

  class NotAuthenticated < StandardError
  end
end

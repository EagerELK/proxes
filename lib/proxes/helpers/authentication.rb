# frozen_string_literal: true
module ProxES
  module Helpers
    module Authentication
      def current_user
        env['warden'] ? env['warden'].user : nil
      end

      def current_user=(user)
        p user
        env['warden'].set_user(user)
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
end

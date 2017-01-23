# frozen_string_literal: true
module ProxES
  module Helpers
    module Authentication
      def current_user
        return nil unless env['rack.session'] && env['rack.session']['user_id']
        @user ||= User[env['rack.session']['user_id']]
      end

      def current_user=(user)
        env['rack.session']['user_id'] = user.id
      end

      def authenticate
        authenticated?
      end

      def authenticated?
        !env['rack.session']['user_id'].nil?
      end

      def authenticate!
        raise NotAuthenticated unless env['rack.session']['user_id']
        true
      end

      def logout
        env['rack.session'].delete('user_id')
      end
    end

    class NotAuthenticated < StandardError
    end
  end
end

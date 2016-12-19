# frozen_string_literal: true
require 'active_support'
require 'active_support/inflector'

module ProxES
  module Helpers
    module Component
      def dataset
        policy_scope(settings.model_class)
      end

      def list
        params['count'] = params['count'] ? params['count'].to_i : 10
        params['page'] = params['page'] ? params['page'].to_i : 1

        dataset.select.paginate(params['page'], params['count'])
      end

      def heading(action = nil)
        heading = ActiveSupport::Inflector.demodulize settings.model_class
        case action
        when :list
          ActiveSupport::Inflector.pluralize heading
        when :new
          "New #{heading}"
        when :edit
          "Edit #{heading}"
        else
          heading
        end
      end

      def base_path
        settings.base_path || "/#{heading(:list).downcase}"
      end

      def view_location
        settings.view_location || heading(:list).downcase.to_s
      end
    end
  end
end

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
        params['count'] ||= 10
        params['page'] ||= 1

        dataset.select.paginate(params['page'].to_i, params['count'].to_i)
      end

      def heading(action = nil)
        @headings ||= begin
          heading = ActiveSupport::Inflector.demodulize settings.model_class
          h = Hash.new(heading)
          h[:new] = "New #{heading}"
          h[:list] = ActiveSupport::Inflector.pluralize heading
          h[:edit] = "Edit #{heading}"
          h
        end
        @headings[action]
      end

      def base_path
        settings.base_path || "/_proxes/#{heading(:list).downcase}"
      end

      def view_location
        settings.view_location || heading(:list).underscore.to_s
      end
    end
  end
end

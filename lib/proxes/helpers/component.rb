# frozen_string_literal: true

require 'active_support'
require 'active_support/inflector'

module ProxES
  module Helpers
    module Component
      include ActiveSupport::Inflector

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
          heading = titleize(demodulize(settings.model_class))
          h = Hash.new(heading)
          h[:new] = "New #{heading}"
          h[:list] = pluralize heading
          h[:edit] = "Edit #{heading}"
          h
        end
        @headings[action]
      end

      def dehumanized
        settings.dehumanized || underscore(heading)
      end

      def base_path
        settings.base_path || "/_proxes/#{dasherize(view_location)}"
      end

      def view_location
        return settings.view_location if settings.view_location
        return underscore(pluralize(demodulize(settings.model_class))) if settings.model_class
        underscore(demodulize(self.class))
      end
    end
  end
end

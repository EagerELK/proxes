# frozen_string_literal: true
require 'pundit'
require 'proxes/request'

module ProxES
  module Helpers
    module Pundit
      include ::Pundit

      def authorize(record, query = nil)
        if record.is_a?(::ProxES::Request)
          query = record.request_method.downcase
        elsif query.nil?
          raise ArgumentError, 'Pundit cannot determine the query'
        end
        query = :"#{query}?" unless query[-1] == '?'
        super
      end

      def permitted_attributes(record, action)
        param_key = PolicyFinder.new(record).param_key
        policy = policy(record)
        method_name = if policy.respond_to?("permitted_attributes_for_#{action}")
                        "permitted_attributes_for_#{action}"
                      else
                        'permitted_attributes'
                      end

        request.params.fetch(param_key, {}).select do |key, _value|
          policy.public_send(method_name).include? key.to_sym
        end
      end

      def pundit_user
        current_user
      end
    end
  end
end

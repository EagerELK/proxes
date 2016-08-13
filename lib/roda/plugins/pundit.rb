require 'pundit'
require 'proxes/es_request'

class Roda
  module RodaPlugins
    module Pundit
      def self.configure(app, opts = {})
        policies_path = File.expand_path(opts[:policies]||'policies', app.opts[:root])
        Dir[File.join(policies_path, '/**/*.rb')].each { |file| require file }
      end

      module InstanceMethods
        include ::Pundit

        def authorize(record, query = nil)
          if record.is_a?(::ProxES::ESRequest)
            if record.action.nil? && record.index
              query = '_index?'
            else
              query = record.action ? record.action.to_s + '?' : '_root?'
            end
          else
            raise ArgumentError, 'Pundit cannot determine the query' if query.nil?
          end
          query = query.to_s + '?' unless query[-1] == '?'
          super(record, query)
        end

        def pundit_user
          current_user
        end

        def permitted_attributes(record, action)
          param_key = PolicyFinder.new(record).param_key
          policy = policy(record)
          method_name = if policy.respond_to?("permitted_attributes_for_#{action}")
            "permitted_attributes_for_#{action}"
          else
            'permitted_attributes'
          end

          request.params.fetch(param_key, {}).select do |key, value|
            policy.public_send(method_name).include? key.to_sym
          end
        end
      end
    end

    register_plugin(:pundit, Pundit)
  end
end

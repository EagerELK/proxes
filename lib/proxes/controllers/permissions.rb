# frozen_string_literal: true

require 'ditty/controllers/component'
require 'proxes/models/permission'
require 'proxes/policies/user_policy'
require 'proxes/policies/permission_policy'

module ProxES
  class Permissions < Ditty::Component
    set model_class: Permission

    FILTERS = [
      { name: :user, field: 'user.email' },
      { name: :role, field: 'role.name' },
      { name: :verb }
    ].freeze

    SEARCHABLE = %i[pattern]

    helpers do
      def user_options
        policy_scope(::Ditty::User).as_hash(:email, :email)
      end

      def role_options
        policy_scope(::Ditty::Role).as_hash(:name, :name)
      end

      def verb_options
        ProxES::Permission.verbs
      end
    end

    def find_template(views, name, engine, &block)
      super(views, name, engine, &block) # Root
      super(::Ditty::ProxES.view_folder, name, engine, &block) # This Component
      super(::Ditty::App.view_folder, name, engine, &block) # Ditty
    end
  end
end

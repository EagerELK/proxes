# frozen_string_literal: true

require 'ditty/controllers/component_controller'
require 'proxes/models/permission'
require 'ditty/policies/user_policy'
require 'ditty/policies/role_policy'
require 'proxes/policies/permission_policy'

module ProxES
  class PermissionsController < Ditty::ComponentController
    set model_class: Permission
    set view_folder: ::Ditty::ProxES.view_folder

    FILTERS = [
      { name: :user, field: 'user.email' },
      { name: :role, field: 'role.name' },
      { name: :verb }
    ].freeze

    SEARCHABLE = %i[pattern].freeze

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
  end
end

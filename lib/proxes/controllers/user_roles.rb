# frozen_string_literal: true
require 'proxes/controllers/component'
require 'proxes/models/user_role'
require 'proxes/policies/user_role_policy'

module ProxES
  class UserRoles < Component
    set model_class: ProxES::UserRole
    set view_location: 'user_roles'
    set base_path: '/_proxes/user-roles'
  end
end

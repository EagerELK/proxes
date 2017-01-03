# frozen_string_literal: true
require 'proxes/controllers/component'
require 'proxes/models/role'
require 'proxes/policies/role_policy'

module ProxES
  class Roles < Component
    set model_class: ProxES::Role
    set view_location: 'roles'
    set base_path: '/_proxes/roles'
  end
end

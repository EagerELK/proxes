# frozen_string_literal: true

require 'proxes/controllers/component'
require 'proxes/models/role'
require 'proxes/policies/role_policy'

module ProxES
  class Roles < Component
    set model_class: Role
  end
end

# frozen_string_literal: true
require 'proxes/controllers/component'
require 'proxes/models/permission'
require 'proxes/policies/permission_policy'

module ProxES
  class Permissions < Component
    set model_class: ProxES::Permission
    set view_location: 'permissions'
    set base_path: '/_proxes/permissions'
  end
end

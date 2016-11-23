require 'proxes/controllers/component'
require 'proxes/models/user_role'

module ProxES
  class UserRoles < Component
    set model_class: ProxES::UserRole
    set view_location: 'user_roles'
    set base_path: '/user-roles'
  end
end

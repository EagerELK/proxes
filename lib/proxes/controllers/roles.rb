# frozen_string_literal: true

require 'proxes/controllers/component'
require 'proxes/models/role'
require 'proxes/policies/role_policy'

module ProxES
  class Roles < Component
    set model_class: Role

    def find_template(views, name, engine, &block)
      super(views, name, engine, &block) # Root
      super(::ProxES::ProxES.view_folder, name, engine, &block) # Basic Plugin
    end
  end
end

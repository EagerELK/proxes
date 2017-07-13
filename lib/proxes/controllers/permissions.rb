# frozen_string_literal: true

require 'proxes/controllers/component'
require 'proxes/models/permission'
require 'proxes/policies/permission_policy'

module ProxES
  class Permissions < Component
    set model_class: Permission

    def find_template(views, name, engine, &block)
      super(views, name, engine, &block) # Root
      super(::ProxES::ProxES.view_folder, name, engine, &block) # Basic Plugin
    end
  end
end

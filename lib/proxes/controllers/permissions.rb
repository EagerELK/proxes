# frozen_string_literal: true

require 'ditty/controllers/component'
require 'proxes/models/permission'
require 'proxes/policies/permission_policy'

module ProxES
  class Permissions < Ditty::Component
    set model_class: Permission

    def find_template(views, name, engine, &block)
      super(views, name, engine, &block) # Root
      super(::Ditty::ProxES.view_folder, name, engine, &block) # This Component
      super(::Ditty::App.view_folder, name, engine, &block) # Ditty
    end
  end
end

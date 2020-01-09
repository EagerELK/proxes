# frozen_string_literal: true

require 'ditty/controllers/component_controller'
require 'proxes/policies/status_check_policy'
require 'proxes/models/status_check'

module ProxES
  class StatusChecksController < Ditty::ComponentController
    set model_class: StatusCheck
    set view_folder: ::Ditty::ProxES.view_folder

    def ordering
      return Sequel.asc(:order) if params[:sort].blank?

      Sequel.send(params[:order].to_sym, params[:sort].to_sym)
    end
  end
end

# frozen_string_literal: true
require 'proxes/controllers/application'
require 'proxes/helpers/component'
require 'proxes/models/audit_log'
require 'proxes/policies/audit_log_policy'

module ProxES
  class AuditLogs < Application
    helpers ProxES::Helpers::Component
    set model_class: ProxES::AuditLog

   # List
    get '/', provides: [:html, :json] do
      authorize settings.model_class, :list

      respond_to do |format|
        format.html do
          haml :"audit_logs/index",
            locals: { list: list, title: heading(:list) }
        end
        format.json do
          {
            'items' => list.map { |entity| entity.values },
            'page' => params[:page],
            'count' => params[:count],
            'total' => list.to_a.size
          }.to_json
        end
      end
    end
  end
end

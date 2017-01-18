# frozen_string_literal: true
require 'proxes/controllers/component'
require 'proxes/models/audit_log'
require 'proxes/policies/audit_log_policy'

module ProxES
  class AuditLogs < Component
    set model_class: ProxES::AuditLog
    set view_location: 'audit_logs'
    set base_path: '/_proxes/audit_logs'

    get '/' do
      halt 404
    end
  end
end

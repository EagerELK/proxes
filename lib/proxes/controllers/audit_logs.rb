# frozen_string_literal: true
require 'proxes/controllers/component'
require 'proxes/models/audit_log'
require 'proxes/policies/audit_log_policy'
# require 'pry'

module ProxES
  class AuditLogs < Component
    set model_class: ProxES::AuditLog
    # set view_location: 'audit_log'
    # set base_path: '/_proxes/audit_log'

    # get '/' do
    #   binding.pry
    # end
  end
end

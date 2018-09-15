# frozen_string_literal: true

require 'wisper'
require 'ditty/models/audit_log'
require 'ditty/services/logger'

module ProxES
  class Listener
    def es_request_failed(request, response)
      Ditty::AuditLog.create(
        action: :es_request_failed,
        user: request.user,
        details: "#{request.detail} > #{response[0]}"
      )
    end

    def es_request_denied(request, exception = nil)
      detail = request.detail
      detail = "#{detail} - #{exception.class}" if exception
      Ditty::Services::Logger.error exception if exception
      Ditty::AuditLog.create(
        action: :es_request_denied,
        user: request.user,
        details: detail
      )
    end
  end
end

Wisper.subscribe(ProxES::Listener.new) unless ENV['RACK_ENV'] == 'test'

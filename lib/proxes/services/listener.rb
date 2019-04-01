# frozen_string_literal: true

require 'wisper'
require 'ditty/models/audit_log'
require 'ditty/services/logger'
require 'browser/browser'

module ProxES
  class Listener
    def user_login(details)
      target = details[:target]
      if target.request.session['omniauth.origin'].nil? && target.request.accept?('text/html')
        target.request.session['omniauth.origin'] = '/_proxes'
      end
    end

    def es_request_failed(request, response)
      Ditty::AuditLog.create(
        user_traits(request).merge(
          action: :es_request_failed,
          user: request.user,
          details: "#{request.detail} > #{response[0]}"
        )
      )
    end

    def es_request_denied(request, exception = nil)
      detail = request.detail
      if exception
        detail = "#{detail} - #{exception.class}"
        Ditty::Services::Logger.error exception
      end
      Ditty::AuditLog.create(
        user_traits(request).merge(
          action: :es_request_denied,
          user: request.user,
          details: detail
        )
      )
    end

    def user_traits(request)
      browser = Browser.new(request.user_agent, accept_language: request.env['HTTP_ACCEPT_LANGUAGE'])
      {
        platform: browser.platform.name,
        device: browser.device.name,
        browser: browser.name,
        ip_address: request.ip
      }
    end
  end
end

Wisper.subscribe(ProxES::Listener.new) unless ENV['RACK_ENV'] == 'test'

# frozen_string_literal: true

require 'proxes/controllers/component'
require 'proxes/models/audit_log'
require 'proxes/policies/audit_log_policy'

module ProxES
  class AuditLogs < Component
    set model_class: AuditLog

    def list
      super.order(:created_at).reverse
    end

    get '/new' do
      halt 404
    end

    post '/' do
      halt 404
    end

    get '/:id' do
      halt 404
    end

    get '/:id/edit' do
      halt 404
    end

    put '/:id' do
      halt 404
    end

    delete '/:id' do
      halt 404
    end
  end
end

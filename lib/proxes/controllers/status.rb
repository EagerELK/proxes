# frozen_string_literal: true

require 'ditty/controllers/application'
require 'proxes/policies/status_policy'
require 'proxes/models/status_check'
require 'proxes/services/es'

module ProxES
  class Status < Ditty::Application
    set view_folder: ::Ditty::ProxES.view_folder

    include ProxES::Services::ES

    # This provides a URL that can be polled by a monitoring system. It will return
    # 200 OK if all the checks pass, or 500 if any of the checks fail.
    get '/check' do
      checks = []
      ProxES::StatusCheck.es_client = client_with_context(user_id: current_user&.id)

      begin
        # Programmed checks
        ProxES::StatusCheck.order(:order).all.each do |sc|
          checks << {
            text: sc.name,
            passed: sc.passed?,
            check: sc.required_value,
            value: sc.value,
            children: sc.children,
            entity: sc
          }
        end

        # Default Check
        checks.unshift(
          text: 'Cluster Reachable',
          passed: true,
          value: ProxES::StatusCheck.source_result('health')['cluster_name']['cluster_name']
        )
      rescue Faraday::Error => e
        checks << { text: 'Cluster Reachable', passed: false, value: e.message }
      end

      passed = checks.find { |c| c[:passed] == false }.nil?
      code = passed ? 200 : 500

      status code
      respond_to do |format|
        format.html do
          haml :'status/check', locals: { title: 'Status Check', checks: checks, passed: passed }
        end
        format.json do
          json checks: checks, passed: passed, code: code
        end
      end
    end
  end
end

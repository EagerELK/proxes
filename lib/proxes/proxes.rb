# frozen_string_literal: true
require 'proxes'
require 'proxes/db'
require 'proxes/controllers/users'
require 'proxes/controllers/roles'
require 'proxes/controllers/permissions'
require 'proxes/controllers/audit_logs'

module ProxES
  class ProxES
    def self.migration_folder
      File.expand_path('../../../migrate', __FILE__)
    end

    def self.route_mappings
      {
        '/' => App,
        '/users' => Users,
        '/roles' => Roles,
        '/permissions' => Permissions,
        '/audit-logs' => AuditLogs,
      }
    end

    def self.nav_items
      [
        { order: 0, link:'/users/', text: 'Users' },
        { order: 1, link:'/roles/', text: 'Roles' },
        { order: 2, link:'/permissions/', text: 'Permissions' },
      ]
    end
  end
end

ProxES::Container::Plugins.register_plugin(:proxes, ProxES::ProxES)

# frozen_string_literal: true

module ProxES
  class ProxES
    def self.migration_folder
      File.expand_path('../../../migrate', __FILE__)
    end

    def self.route_mappings
      require 'proxes/app'
      require 'proxes/controllers/users'
      require 'proxes/controllers/roles'
      require 'proxes/controllers/permissions'
      require 'proxes/controllers/audit_logs'

      {
        '/' => ::ProxES::App,
        '/users' => ::ProxES::Users,
        '/roles' => ::ProxES::Roles,
        '/permissions' => ::ProxES::Permissions,
        '/audit-logs' => ::ProxES::AuditLogs,
      }
    end

    def self.nav_items
      [
        { order: 0, link:'/users/', text: 'Users', target: User, icon: 'user' },
        { order: 1, link:'/roles/', text: 'Roles', target: Role, icon: 'group' },
        { order: 2, link:'/permissions/', text: 'Permissions', target: Permission, icon: 'check-square' },
      ]
    end
  end
end

ProxES::Container::Plugins.register_plugin(:proxes, ProxES::ProxES)

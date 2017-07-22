# frozen_string_literal: true

module ProxES
  class ProxES
    def self.migration_folder
      File.expand_path('../../../migrate', __FILE__)
    end

    def self.view_folder
      File.expand_path('../../../views', __FILE__)
    end

    def self.route_mappings
      controllers = File.expand_path('../controllers', __FILE__)
      Dir.glob("#{controllers}/*.rb").each { |f| require f }
      {
        '/' => ::ProxES::App,
        '/users' => ::ProxES::Users,
        '/roles' => ::ProxES::Roles,
        '/permissions' => ::ProxES::Permissions,
        '/audit-logs' => ::ProxES::AuditLogs
      }
    end

    def self.nav_items
      [
        { order: 0, link: '/users/', text: 'Users', target: User, icon: 'user' },
        { order: 1, link: '/roles/', text: 'Roles', target: Role, icon: 'group' },
        { order: 2, link: '/permissions/', text: 'Permissions', target: Permission, icon: 'check-square' },
        { order: 3, link: '/audit-logs/', text: 'Audit Logs', target: AuditLog, icon: 'history' }
      ]
    end

    def self.seeder
      proc do
        require 'proxes/models/user'
        require 'proxes/models/role'

        sa = ::ProxES::Role.find_or_create(name: 'super_admin')
        %w[GET POST PUT DELETE HEAD OPTIONS INDEX].each do |verb|
          ::ProxES::Permission.find_or_create(role: sa, verb: verb, pattern: '.*')
        end
        ::ProxES::Role.find_or_create(name: 'admin')
        ::ProxES::Role.find_or_create(name: 'user')

        anon = ::ProxES::User.find_or_create(email: 'anonymous@proxes.io')
        anon_role = ::ProxES::Role.find_or_create(name: 'anonymous')
        anon.add_role anon_role unless anon.role?('anonymous')
        # Kibana Specific
        ::ProxES::Permission.find_or_create(role: anon_role, verb: 'GET', pattern: '/.kibana/config/*')
        ::ProxES::Permission.find_or_create(role: anon_role, verb: 'INDEX', pattern: '.kibana')
      end
    end
  end
end

ProxES::Container::Plugins.register_plugin(:proxes, ProxES::ProxES)

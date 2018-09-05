# frozen_string_literal: true

require 'ditty'

module Ditty
  class ProxES
    def self.load
      controllers = File.expand_path('../../proxes/controllers', __dir__)
      Dir.glob("#{controllers}/*.rb").each { |f| require f }
      require 'proxes/models/permission'
      require 'proxes/services/listener'
    end

    def self.migrations
      File.expand_path('../../../migrate', __dir__)
    end

    def self.view_folder
      File.expand_path('../../../views', __dir__)
    end

    def self.public_folder
      File.expand_path('../../../public', __dir__)
    end

    def self.routes
      load
      {
        '/search' => ::ProxES::Search,
        '/status' => ::ProxES::Status,
        '/permissions' => ::ProxES::Permissions
      }
    end

    def self.navigation
      load
      [
        { order: 0, link: '/status/check', text: 'Status Check', target: ::ProxES::Status, icon: 'dashboard' },
        { order: 1, link: '/search', text: 'Search', target: ::ProxES::Status, icon: 'search' },
        { order: 15, link: '/permissions', text: 'Permissions', target: ::ProxES::Permission, icon: 'check-square' }
      ]
    end

    def self.seeder
      proc do
        require 'ditty/models/user'
        require 'ditty/models/role'
        require 'proxes/models/permission'

        sa = ::Ditty::Role.find_or_create(name: 'super_admin')
        %w[GET POST PUT DELETE HEAD OPTIONS INDEX].each do |verb|
          ::ProxES::Permission.find_or_create(role: sa, verb: verb, pattern: '.*')
        end

        # Admin Role
        ::Ditty::Role.find_or_create(name: 'admin')

        # User Role
        user_role = ::Ditty::Role.find_or_create(name: 'user')
        ::ProxES::Permission.find_or_create(role: user_role, verb: 'GET', pattern: '/_cluster/stats')
        ::ProxES::Permission.find_or_create(role: user_role, verb: 'GET', pattern: '/_nodes')
        ::ProxES::Permission.find_or_create(role: user_role, verb: 'GET', pattern: '/_nodes/stats')
        ::ProxES::Permission.find_or_create(role: user_role, verb: 'GET', pattern: '/_stats')
        ::ProxES::Permission.find_or_create(role: user_role, verb: 'INDEX', pattern: 'user-{user.id}.*')

        # Kibana Specific
        # actions: ["indices:data/read/field_stats", "indices:admin/mappings/fields/get", "indices:admin/get", "indices:data/read/msearch"]
        anon_role = ::Ditty::Role.find_or_create(name: 'anonymous')
        ::Ditty::User.create_anonymous_user('anonymous@proxes.io')
        ::ProxES::Permission.find_or_create(role: anon_role, verb: 'GET', pattern: '/.kibana/config/.*')
        ::ProxES::Permission.find_or_create(role: anon_role, verb: 'INDEX', pattern: '.kibana')

        kibana = ::Ditty::Role.find_or_create(name: 'kibana')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'INDEX', pattern: '.kibana')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'HEAD', pattern: '/')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'GET', pattern: '/_nodes*')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'GET', pattern: '/_cluster/health.*')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'GET', pattern: '/_cluster/settings.*')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'POST', pattern: '/_mget')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'POST', pattern: '/_search')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'POST', pattern: '/_msearch')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'POST', pattern: '/_refresh')
      end
    end
  end
end

Ditty::Components.register_component(:proxes, Ditty::ProxES)

# frozen_string_literal: true

require 'ditty'

module Ditty
  class ProxES
    def self.load
      controllers = File.expand_path('../../../proxes/controllers', __FILE__)
      Dir.glob("#{controllers}/*.rb").each { |f| require f }
      require 'proxes/models/permission'
    end

    def self.migrations
      File.expand_path('../../../../migrate', __FILE__)
    end

    def self.view_folder
      File.expand_path('../../../../views', __FILE__)
    end

    def self.public_folder
      File.expand_path('../../../../public', __FILE__)
    end

    def self.routes
      load
      {
        '/status' => ::ProxES::Status,
        '/permissions' => ::ProxES::Permissions
      }
    end

    def self.navigation
      load
      [
        { order: 0, link: '/status/check', text: 'Status Check', target: ::ProxES::Status, icon: 'dashboard' },
        { order: 15, link: '/permissions/', text: 'Permissions', target: ::ProxES::Permission, icon: 'check-square' }
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
        ::Ditty::Role.find_or_create(name: 'admin')
        user_role = ::Ditty::Role.find_or_create(name: 'user')

        # Kibana Specific
        anon = ::Ditty::User.find_or_create(email: 'anonymous@proxes.io')
        anon.remove_role user_role
        anon_role = ::Ditty::Role.find_or_create(name: 'anonymous')
        anon.add_role anon_role unless anon.role?('anonymous')
        ::ProxES::Permission.find_or_create(role: anon_role, verb: 'GET', pattern: '/.kibana/config/*')
        ::ProxES::Permission.find_or_create(role: anon_role, verb: 'INDEX', pattern: '.kibana')

        kibana = ::Ditty::Role.find_or_create(name: 'kibana')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'INDEX', pattern: '.kibana')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'HEAD', pattern: '/')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'GET', pattern: '/_nodes*')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'GET', pattern: '/_cluster/health*')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'GET', pattern: '/_cluster/settings*')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'POST', pattern: '/_mget')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'POST', pattern: '/_search')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'POST', pattern: '/_msearch')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'POST', pattern: '/_refresh')
      end
    end
  end
end

Ditty::Components.register_component(:proxes, Ditty::ProxES)

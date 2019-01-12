# frozen_string_literal: true

require 'ditty'

module Ditty
  class ProxES
    def self.load
      controllers = File.expand_path('../../proxes/controllers', __dir__)
      Dir.glob("#{controllers}/*.rb").each { |f| require f }
      ENV['ELASTICSEARCH_URL'] ||= 'http://localhost:9200'
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
        { order: 1, link: '/search', text: 'Search', target: ::ProxES::Search, icon: 'search' },
        { order: 15, link: '/permissions', text: 'Permissions', target: ::ProxES::Permission, icon: 'check-square' }
      ]
    end

    def self.seeder
      proc do
        require 'ditty/models/user'
        require 'ditty/models/role'
        require 'proxes/models/permission'
        require 'proxes/models/status_check'

        sa = ::Ditty::Role.find_or_create(name: 'super_admin')
        %w[GET POST PUT DELETE HEAD OPTIONS].each do |verb|
          ::ProxES::Permission.find_or_create(role: sa, verb: verb, pattern: '*', index: '*')
        end

        # Admin Role
        ::Ditty::Role.find_or_create(name: 'admin')

        # User Role
        user_role = ::Ditty::Role.find_or_create(name: 'user')
        ::ProxES::Permission.find_or_create(role: user_role, verb: 'GET', pattern: '/_cluster/stats')
        ::ProxES::Permission.find_or_create(role: user_role, verb: 'GET', pattern: '/_nodes')
        ::ProxES::Permission.find_or_create(role: user_role, verb: 'GET', pattern: '/_nodes/stats')
        ::ProxES::Permission.find_or_create(role: user_role, verb: 'GET', pattern: '/_stats')
        # TODO
        # ::ProxES::Permission.find_or_create(role: user_role, verb: 'INDEX', pattern: 'user-{user.id}*')

        # Kibana Specific
        anon_role = ::Ditty::Role.find_or_create(name: 'anonymous')
        ::Ditty::User.create_anonymous_user('anonymous@proxes.io')
        ::ProxES::Permission.find_or_create(role: anon_role, verb: 'GET', pattern: '/.kibana/config/*', index: '.kibana')
        ::ProxES::Permission.find_or_create(role: anon_role, verb: 'GET', pattern: '/.kibana/doc/config/*', index: '.kibana')

        kibana = ::Ditty::Role.find_or_create(name: 'kibana')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'HEAD', pattern: '/', index: '.kibana')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'GET', pattern: '/_nodes*', index: '.kibana')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'GET', pattern: '/_cluster/health*', index: '.kibana')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'GET', pattern: '/_cluster/settings*', index: '.kibana')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'POST', pattern: '/_mget', index: '.kibana')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'POST', pattern: '/_search', index: '.kibana')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'POST', pattern: '/_msearch', index: '.kibana')
        ::ProxES::Permission.find_or_create(role: kibana, verb: 'POST', pattern: '/_refresh', index: '.kibana')

        # Status Check
        ::ProxES::StatusCheck.find_or_create(
          type: 'ProxES::ClusterHealthStatusCheck',
          name: 'Cluster Health',
          source: 'health'
        ) { |r| r.set(required_value: 'green', order: 20) }
        ::ProxES::StatusCheck.find_or_create(
          type: 'ProxES::MasterNodesStatusCheck',
          name: 'Master Nodes',
          source: 'node_stats'
        ) { |r| r.set(required_value: 1, order: 30) }
        ::ProxES::StatusCheck.find_or_create(
          type: 'ProxES::DataNodesStatusCheck',
          name: 'Data Nodes',
          source: 'node_stats'
        ) { |r| r.set(required_value: 1, order: 40) }
        ::ProxES::StatusCheck.find_or_create(
          type: 'ProxES::IngestNodesStatusCheck',
          name: 'Ingest Nodes',
          source: 'node_stats'
        ) { |r| r.set(required_value: 1, order: 50) }
        ::ProxES::StatusCheck.find_or_create(
          type: 'ProxES::JVMHeapStatusCheck',
          name: 'Node JVM Heap',
          source: 'node_stats'
        ) { |r| r.set(required_value: 85, order: 60) }
        ::ProxES::StatusCheck.find_or_create(
          type: 'ProxES::FileSystemStatusCheck',
          name: 'Node File Systems',
          source: 'node_stats'
        ) { |r| r.set(required_value: 10, order: 70) }
        ::ProxES::StatusCheck.find_or_create(
          type: 'ProxES::CPUStatusCheck',
          name: 'Node CPU Usage',
          source: 'node_stats'
        ) { |r| r.set(required_value: 70, order: 80) }
        ::ProxES::StatusCheck.find_or_create(
          type: 'ProxES::MemoryStatusCheck',
          name: 'Node Memory Usage',
          source: 'node_stats'
        ) { |r| r.set(required_value: 99, order: 90) }
      end
    end
  end
end

Ditty::Components.register_component(:proxes, Ditty::ProxES)

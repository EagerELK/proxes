require 'proxes/base'
require 'proxes/routes'

module ProxES
  # Manage your Elasticsearch cluster, user and user sessions
  class App < ProxES::Base
    plugin :multi_route

    def logger
      require 'logger'
      @logger ||= Logger.new($stdout)
    end

    def root_url
      @root_url = opts[:root_url] || '/_proxes'
    end

    route do |r|
      r.multi_route

      r.public

      r.get do
        authenticate!

        view 'index'
      end
    end
  end
end

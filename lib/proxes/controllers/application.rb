# frozen_string_literal: true

require 'wisper'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/respond_with'
require 'proxes/helpers/views'
require 'proxes/helpers/pundit'
require 'proxes/helpers/wisper'
require 'proxes/helpers/authentication'
require 'proxes/services/logger'
require 'rack/contrib'
require 'elasticsearch'
require 'active_support'
require 'active_support/inflector'

module ProxES
  class Application < Sinatra::Base
    include ActiveSupport::Inflector

    set :root, ENV['APP_ROOT'] || ::File.expand_path(::File.dirname(__FILE__) + '/../../../')
    set :view_location, nil
    set :model_class, nil
    # The order here is important, since Wisper has a deprecated method respond_with method
    helpers Wisper::Publisher, Helpers::Wisper
    helpers Helpers::Pundit, Helpers::Views, Helpers::Authentication

    def find_template(views, name, engine, &block)
      super(views, name, engine, &block) # Root
      super(::ProxES::ProxES.view_folder, name, engine, &block) # Basic Plugin
    end

    helpers do
      def cluster_health
        @health ||= begin
          client = ::Elasticsearch::Client.new host: ENV['ELASTICSEARCH_URL']
          client.cluster.health
        end
      rescue => e
        ::ProxES::Services::Logger.instance.warn "Could not connect to ES Cluster: #{e.message}"
        nil
      end
    end

    register Sinatra::Flash, Sinatra::RespondWith

    use Rack::PostBodyContentTypeParser
    use Rack::MethodOverride

    configure :production do
      disable :show_exceptions
    end

    configure :development do
      set :show_exceptions, :after_handler
    end

    configure :production, :development do
      enable :logging
    end

    not_found do
      haml :'404', locals: { title: '4 oh 4' }
    end

    error do
      error = env['sinatra.error']
      haml :error, locals: { title: 'Something went wrong', message: error }
    end

    error Helpers::NotAuthenticated do
      flash[:warning] = 'Please log in first.'
      redirect '/_proxes/auth/identity'
    end

    error ::Pundit::NotAuthorizedError do
      flash[:warning] = 'Please log in first.'
      redirect '/_proxes/auth/identity'
    end

    error ::Faraday::ConnectionFailed do
      error = env['sinatra.error']
      uri = URI.parse ENV['ELASTICSEARCH_URL']
      raise error unless error.message.include? "#{uri.host}:#{uri.port}"
      flash[:warning] = 'Functionality currently unavailable. Cluster Offline.'
      redirect '/_proxes'
    end

    before(/.*/) do
      ::ProxES::Services::Logger.instance.debug "Running with #{self.class}"
      if request.url =~ /.json/
        request.accept.unshift('application/json')
        request.path_info = request.path_info.gsub(/.json/, '')
      end
    end
  end
end

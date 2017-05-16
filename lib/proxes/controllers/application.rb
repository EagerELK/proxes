# frozen_string_literal: true

require 'wisper'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/respond_with'
require 'proxes/helpers/views'
require 'proxes/helpers/pundit'
require 'proxes/helpers/wisper'
require 'proxes/helpers/authentication'
require 'rack/contrib'

module ProxES
  class Application < Sinatra::Base
    set :root, ::File.expand_path(::File.dirname(__FILE__) + '/../../../')
    # The order here is important, since Wisper has a deprecated method respond_with method
    helpers Wisper::Publisher, Helpers::Wisper
    helpers Helpers::Pundit, Helpers::Views, Helpers::Authentication

    helpers do
      def cluster_health
        @health ||= begin
          client = Elasticsearch::Client.new
          client.cluster.health
        end
      rescue
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
      redirect '/auth/identity'
    end

    error ::Pundit::NotAuthorizedError do
      flash[:warning] = 'Please log in first.'
      redirect '/auth/identity'
    end

    before(/.*/) do
      if request.url =~ /.json/
        request.accept.unshift('application/json')
        request.path_info = request.path_info.gsub(/.json/, '')
      end
    end
  end
end

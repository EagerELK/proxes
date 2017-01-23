# frozen_string_literal: true
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/respond_with'
require 'proxes/helpers/views'
require 'proxes/helpers/pundit'
require 'proxes/helpers/authentication'

module ProxES
  class Application < Sinatra::Base
    set :root, ::File.expand_path(::File.dirname(__FILE__) + '/../../../')
    register Sinatra::Flash, Sinatra::RespondWith
    helpers ProxES::Helpers::Pundit, ProxES::Helpers::Views, ProxES::Helpers::Authentication

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

    error ::ProxES::Helpers::NotAuthenticated do
      flash[:warning] = 'Please log in first.'
      redirect '/auth/identity'
    end

    error ::Pundit::NotAuthorizedError do
      flash[:warning] = 'Please log in first.'
      redirect '/auth/identity'
    end

    before (/.*/) do
      if request.url.match(/.json/)
        request.accept.unshift('application/json')
        request.path_info = request.path_info.gsub(/.json/,'')
      end
    end
  end
end

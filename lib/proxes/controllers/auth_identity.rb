# frozen_string_literal: true
require 'proxes/controllers/application'

module ProxES
  class AuthIdentity < Application
    get '/auth/identity' do
      haml :'identity/login', locals: { title: 'Log In' }
    end

    # Failed Login
    post '/_proxes/auth/identity/callback' do
      broadcast(:identity_failed_login)
      flash[:warning] = 'Invalid credentials. Please try again.'
      redirect '/auth/identity'
    end

    get '/auth/identity/register' do
      identity = Identity.new
      haml :'identity/register', locals: { title: 'Register', identity: identity }
    end
  end
end

# frozen_string_literal: true

require 'proxes/controllers/application'

module ProxES
  class App < Application
    # Home Page
    get '/' do
      authenticate!
      haml :index, locals: { title: 'Dashboard' }
    end

    # OmniAuth Identity Stuff
    # Log in Page
    get '/_proxes/auth/identity' do
      haml :'identity/login', locals: { title: 'Log In' }
    end

    # Successful Login
    post '/auth/identity/callback' do
      user = User.find(email: env['omniauth.auth']['info']['email'])
      self.current_user = user
      log_action(:identity_login, user: user)
      flash[:success] = 'Logged In'
      redirect '/_proxes'
    end

    # Failed Login
    post '/_proxes/auth/identity/callback' do
      broadcast(:identity_failed_login)
      flash[:warning] = 'Invalid credentials. Please try again.'
      redirect '/_proxes/auth/identity'
    end

    # Register Page
    get '/_proxes/auth/identity/register' do
      identity = Identity.new
      haml :'identity/register', locals: { title: 'Register', identity: identity }
    end

    # Register Action
    post '/auth/identity/new' do
      identity = Identity.new(params['identity'])
      if identity.valid? && identity.save
        user = User.find_or_create(email: identity.username)
        user.add_identity identity

        log_action(:identity_register, user: user)
        flash[:info] = 'Successfully Registered. Please log in'
        redirect '/_proxes/auth/identity'
      else
        flash.now[:warning] = 'Could not complete the registration. Please try again.'
        haml :'identity/register', locals: { identity: identity }
      end
    end

    # Logout Action
    delete '/_proxes/auth/identity' do
      log_action(:identity_logout)
      logout
      flash[:info] = 'Logged Out'

      redirect '/_proxes'
    end

    # Unauthenticated
    get '/_proxes/unauthenticated' do
      redirect '/_proxes/auth/identity'
    end
  end
end

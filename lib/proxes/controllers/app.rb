# frozen_string_literal: true

require 'proxes/controllers/application'

module ProxES
  class App < Application
    def find_template(views, name, engine, &block)
      super(views, name, engine, &block) # Root
      super(::ProxES::ProxES.view_folder, name, engine, &block) # Basic Plugin
    end

    # Home Page
    get '/' do
      authenticate!
      haml :index, locals: { title: 'Home' }
    end

    # OmniAuth Identity Stuff
    # Log in Page
    get '/auth/identity' do
      haml :'identity/login', locals: { title: 'Log In' }
    end

    post '/auth/identity/callback' do
      if env['omniauth.auth']
        # Successful Login
        user = User.find(email: env['omniauth.auth']['info']['email'])
        self.current_user = user
        log_action(:identity_login, user: user)
        flash[:success] = 'Logged In'
        redirect '/_proxes'
      else
        # Failed Login
        broadcast(:identity_failed_login)
        flash[:warning] = 'Invalid credentials. Please try again.'
        redirect '/_proxes/auth/identity'
      end
    end

    # Register Page
    get '/auth/identity/register' do
      identity = Identity.new
      haml :'identity/register', locals: { title: 'Register', identity: identity }
    end

    # Register Action
    post '/auth/identity/new' do
      identity = Identity.new(params['identity'])
      if identity.valid? && identity.save
        user = User.find_or_create(email: identity.username)
        user.add_identity identity

        # Create the SA user if none is present
        sa = Role.find_or_create(name: 'super_admin')
        user.add_role sa if User.where(roles: sa).count == 0

        log_action(:identity_register, user: user)
        flash[:info] = 'Successfully Registered. Please log in'
        redirect '/_proxes/auth/identity'
      else
        flash.now[:warning] = 'Could not complete the registration. Please try again.'
        haml :'identity/register', locals: { identity: identity }
      end
    end

    # Logout Action
    delete '/auth/identity' do
      log_action(:identity_logout)
      logout
      flash[:info] = 'Logged Out'

      redirect '/_proxes'
    end

    # Unauthenticated
    get '/unauthenticated' do
      redirect '/_proxes/auth/identity'
    end
  end
end

require 'proxes/controllers/application'

module ProxES
  # Manage your Elasticsearch cluster, user and user sessions
  class App < Application
    get '/' do
      authenticate!
      haml :index
    end

    ['/unauthenticated', '/_proxes/unauthenticated'].each do |path|
      get path do
        redirect '/auth/identity'
      end
    end

    post '/auth/identity/new' do
      identity = Identity.new(params['identity'])
      if identity.valid? && identity.save
        flash[:info] = 'Successfully Registered. Please log in'
        redirect '/auth/identity'
      else
        flash.now[:warning] = 'Could not complete the registration. Please try again.'
        haml :'identity/register', locals: { identity: identity }
      end
    end

    post '/auth/identity/callback' do
      user = User.find_or_create(email: env['omniauth.auth']['info']['email'])
      user.add_user_role role: 'user' unless user.has_role? 'user'
      user.add_user_role(role: 'super_admin') if (user.id == 1 && user.has_role?('super_admin') == false)

      identity = Identity.find(username: user.email)
      user.add_identity identity unless identity.user == user

      set_user user
      flash[:success] = 'Logged In'
      redirect '/_proxes'
    end

    delete '/auth/identity' do
      logout

      flash[:info] = 'Logged Out'

      redirect '/_proxes'
    end
  end
end

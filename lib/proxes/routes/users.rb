require 'proxes/base'

module ProxES
  class App < Base
    plugin :multi_route

    route 'users' do |r|
      locals = {
        title: 'Users'
      }

      # List
      r.root do
        authorize User, :list

        users = policy_scope(User)
        locals[:users] = users
        view 'users/list', locals: locals, layout_opts: { locals: locals }
      end

      # New
      r.get 'new' do
        authorize User, :create

        locals[:title] = 'New User'
        locals[:user] = User.new
        locals[:identity] = Identity.new
        view 'users/new', locals: locals, layout_opts: { locals: locals }
      end

      # Create
      r.post do
        authorize User, :create

        user_params = permitted_attributes(User, :create)
        identity_params = permitted_attributes(Identity, :create)
        user_params['email'] = identity_params['username']
        user     = locals[:user]     = User.new(user_params)
        identity = locals[:identity] = Identity.new(identity_params)
        if identity.valid? && user.valid?
          DB.transaction(:isolation => :serializable) do
            identity.save
            user.save
            user.add_identity identity
          end

          flash[:success] = 'User created'
          r.redirect root_url + "/users/#{user.id}"
        else
          flash.now[:danger] = 'Could not create the user'
          locals[:title] = 'New User'
          view 'users/new', locals: locals, layout_opts: { locals: locals }
        end
      end

      r.on ':id' do |id|
        user = User[id]

        r.halt(404) unless user

        locals[:title] = 'User: ' + user.email
        locals[:user] = user
        locals[:identity] = user.identity_dataset.exclude(crypted_password: nil).first

        # Edit
        r.is 'edit' do
          r.get do
            authorize user, :update

            view 'users/edit', locals: locals, layout_opts: { locals: locals }
          end
        end

        # Read
        r.get do
          authorize user, :get

          view 'users/show', locals: locals, layout_opts: { locals: locals }
        end

        # Update
        r.put do
          authorize user, :update

          user.set(permitted_attributes(user, :update))
          if user.valid? && user.save
            flash[:success] = 'User updated'
            r.redirect root_url + "/users/#{user.id}"
          else
            flash[:danger] = 'Could not update the user'
            view 'users/edit', locals: locals, layout_opts: { locals: locals }
          end
        end

        # Delete
        r.delete do
          authorize user, :delete
          DB.transaction(:isolation => :serializable) do
            user.identity.first.delete
            user.delete
          end
          flash[:success] = 'User deleted'
          r.redirect root_url + '/users'
        end
      end
    end
  end
end

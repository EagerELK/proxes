require 'proxes/controllers/component'
require 'proxes/models/user'
require 'proxes/policies/user_policy'

module ProxES
  class Users < Component
    set model_class: ProxES::User

    # New
    get '/new' do
      authorize settings.model_class, :create

      locals = {
        title: heading(:new),
        entity: User.new,
        identity: Identity.new
      }
      haml :"#{view_location}/new", locals: locals, layout_opts: { locals: locals }
    end

    # Create
    post '/' do
      authorize settings.model_class, :create

      locals = { title: heading(:new) }

      user_params = permitted_attributes(User, :create)
      identity_params = permitted_attributes(Identity, :create)
      user_params['email'] = identity_params['username']
      roles = user_params.delete('user_roles')
      user     = locals[:user]     = User.new(user_params)
      identity = locals[:identity] = Identity.new(identity_params)
      if identity.valid? && user.valid?
        DB.transaction(:isolation => :serializable) do
          identity.save
          user.save
          user.add_identity identity

          if roles
            user.remove_all_user_roles
            roles.each { |role| user.add_user_role(role: role) }
          end
        end

        flash[:success] = 'User created'
        redirect "/_proxes/users/#{user.id}"
      else
        flash.now[:danger] = 'Could not create the user'
        locals[:entity] = user
        locals[:identity] = identity
        haml :"#{view_location}/new", locals: locals
      end
    end

    # Update
    put '/:id' do |id|
      entity = dataset.find(id: id.to_i)
      halt 404 unless entity
      authorize entity, :update

      values = permitted_attributes(settings.model_class, :update)
      roles = values.delete('user_roles')
      entity.set values
      if entity.valid? && entity.save
        if roles
          entity.remove_all_user_roles
          roles.each { |role| entity.add_user_role(role: role) }
        end

        flash[:success] = "#{heading} Updated"
        redirect "/_proxes/users/#{entity.id}"
      else
        haml :"#{view_location}/edit", locals: { entity: entity, title: heading(:edit) }
      end
    end

    # Delete
    delete '/:id' do |id|
      entity = dataset.find(id: id.to_i)
      halt 404 unless entity
      authorize entity, :delete

      entity.remove_all_identity
      entity.remove_all_user_roles
      entity.destroy

      flash[:success] = "#{heading} Deleted"
      redirect "/_proxes/users"
    end
  end
end

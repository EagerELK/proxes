# frozen_string_literal: true
require 'proxes/controllers/component'
require 'proxes/models/user'
require 'proxes/policies/user_policy'
require 'proxes/models/identity'
require 'proxes/policies/identity_policy'

module ProxES
  class Users < Component
    set model_class: ProxES::User

    # New
    get '/new' do
      authorize settings.model_class, :create

      locals = {
        title: heading(:new),
        entity: ProxES::User.new,
        identity: ProxES::Identity.new
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
      roles = user_params.delete('role_id')

      user     = locals[:user]     = User.new(user_params)
      identity = locals[:identity] = Identity.new(identity_params)

      if identity.valid? && user.valid?
        DB.transaction(isolation: :serializable) do
          identity.save
          user.save
          user.add_identity identity
          roles.each do |role_id|
            user.add_role(role_id) unless user.roles.map(&:id).include? role_id.to_i
          end if roles
          user.check_roles
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
      entity = dataset[id.to_i]
      halt 404 unless entity
      authorize entity, :update

      values = permitted_attributes(settings.model_class, :update)
      roles  = values.delete('role_id')
      entity.set values

      identity_params = permitted_attributes(Identity, :create)
      password = identity_params['password']
      password_confirmation = identity_params['password_confirmation']

      if !password.blank? && password == password_confirmation
        identity = Identity.find_or_new(username: values['email'])
        identity.user_id = entity.id
        identity.password = password
        identity.password_confirmation = password_confirmation
      end

      if entity.valid? && (password.blank? || identity&.valid?)
        DB.transaction(isolation: :serializable) do
          identity.save if identity
          entity.save
          entity.remove_all_roles
          roles.each { |role_id| entity.add_role(role_id) } if roles
          entity.check_roles
        end
        flash[:success] = "#{heading} Updated"
        redirect "/_proxes/users/#{entity.id}"
      else
        haml :"#{view_location}/edit", locals: { entity: entity, title: heading(:edit) }
      end
    end

    # Delete
    delete '/:id' do |id|
      entity = dataset[id.to_i]
      halt 404 unless entity
      authorize entity, :delete

      entity.remove_all_identity
      entity.remove_all_roles
      entity.destroy

      flash[:success] = "#{heading} Deleted"
      redirect '/_proxes/users'
    end

    # Profile
    get '/profile' do
      entity = dataset[current_user.id.to_i] if current_user
      halt 404 unless entity
      authorize entity, :read

      actions = {}
      actions["#{base_path}/#{entity.id}/edit"] = "Edit #{heading}" if policy(entity).update?

      haml :"#{view_location}/display", locals: { entity: entity, title: heading, actions: actions }
    end
  end
end

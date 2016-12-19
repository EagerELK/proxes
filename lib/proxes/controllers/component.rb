# frozen_string_literal: true
require 'proxes/controllers/application'
require 'proxes/helpers/component'

module ProxES
  class Component < Application
    helpers ProxES::Helpers::Component
    set base_path: nil
    set view_location: nil

    # List
    get '/' do
      authorize settings.model_class, :list

      actions = {}
      actions["#{base_path}/new"] = "New #{heading}" if policy(settings.model_class).create?

      haml :"#{view_location}/index", locals: { list: list, title: heading(:list), actions: actions }
    end

    # Create Form
    get '/new' do
      authorize settings.model_class, :create

      entity = settings.model_class.new(permitted_attributes(settings.model_class, :create))
      haml :"#{view_location}/new", locals: { entity: entity, title: heading(:new) }
    end

    # Create
    post '/' do
      authorize settings.model_class, :create

      entity = settings.model_class.new(permitted_attributes(settings.model_class, :create))
      if entity.valid? && entity.save
        flash[:success] = "#{heading} Created"
        redirect "#{base_path}/#{entity.id}"
      else
        haml :"#{view_location}/new", locals: { entity: entity, title: heading(:new) }
      end
    end

    # Read
    get '/:id' do |id|
      entity = dataset[id.to_i]
      halt 404 unless entity
      authorize entity, :read

      actions = {}
      actions["#{base_path}/#{entity.id}/edit"] = "Edit #{heading}" if policy(entity).update?

      haml :"#{view_location}/display", locals: { entity: entity, title: heading, actions: actions }
    end

    # Update Form
    get '/:id/edit' do |id|
      entity = dataset.find(id: id.to_i)
      halt 404 unless entity
      authorize entity, :update

      haml :"#{view_location}/edit", locals: { entity: entity, title: heading(:edit) }
    end

    # Update
    put '/:id' do |id|
      entity = dataset.find(id: id.to_i)
      halt 404 unless entity
      authorize entity, :update

      entity.set(permitted_attributes(settings.model_class, :create))
      if entity.valid? && entity.save
        flash[:success] = "#{heading} Updated"
        redirect "#{base_path}/#{entity.id}"
      else
        haml :"#{view_location}/edit", locals: { entity: entity, title: heading(:edit) }
      end
    end

    delete '/:id' do |id|
      entity = dataset.find(id: id.to_i)
      halt 404 unless entity
      authorize entity, :delete

      entity.destroy

      flash[:success] = "#{heading} Deleted"
      redirect base_path.to_s
    end
  end
end

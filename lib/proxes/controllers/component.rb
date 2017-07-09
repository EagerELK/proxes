# frozen_string_literal: true

require 'proxes/controllers/application'
require 'proxes/helpers/component'

module ProxES
  class Component < Application
    helpers Helpers::Component

    set base_path: nil
    set dehumanized: nil
    set view_location: nil
    set track_actions: false

    before do
      check_basic
    end

    # List
    get '/', provides: [:html, :json] do
      authorize settings.model_class, :list

      actions = {}
      actions["#{base_path}/new"] = "New #{heading}" if policy(settings.model_class).create?

      log_action("#{dehumanized}_list".to_sym) if settings.track_actions
      respond_to do |format|
        format.html do
          haml :"#{view_location}/index",
               locals: { list: list, title: heading(:list), actions: actions }
        end
        format.json do
          # TODO: Add links defined by actions (New #{heading})
          {
            'items' => list.map(&:for_json),
            'page' => params[:page],
            'count' => list.count,
            'total' => dataset.count
          }.to_json
        end
      end
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
      success = entity.valid? && entity.save

      log_action("#{dehumanized}_create".to_sym) if success && settings.track_actions
      respond_to do |format|
        format.html do
          if success
            flash[:success] = "#{heading} Created"
            redirect "#{base_path}/#{entity.id}"
          else
            haml :"#{view_location}/new", locals: { entity: entity, title: heading(:new) }
          end
        end
        format.json do
          headers 'Content-Type' => 'application/json'
          redirect "#{base_path}/#{entity.id}", 201 if success
        end
      end
    end

    # Read
    get '/:id' do |id|
      entity = dataset[id.to_i]
      halt 404 unless entity
      authorize entity, :read

      actions = {}
      actions["#{base_path}/#{entity.id}/edit"] = "Edit #{heading}" if policy(entity).update?

      log_action("#{dehumanized}_read".to_sym) if settings.track_actions
      respond_to do |format|
        format.html do
          haml :"#{view_location}/display",
               locals: { entity: entity, title: heading, actions: actions }
        end
        format.json do
          # TODO: Add links defined by actions (Edit #{heading})
          entity.for_json.to_json
        end
      end
    end

    # Update Form
    get '/:id/edit' do |id|
      entity = dataset[id.to_i]
      halt 404 unless entity
      authorize entity, :update

      haml :"#{view_location}/edit", locals: { entity: entity, title: heading(:edit) }
    end

    # Update
    put '/:id' do |id|
      entity = dataset[id.to_i]
      halt 404 unless entity
      authorize entity, :update

      entity.set(permitted_attributes(settings.model_class, :update))

      success = entity.valid? && entity.save
      log_action("#{dehumanized}_update".to_sym) if success && settings.track_actions
      if success
        respond_to do |format|
          format.html do
            flash[:success] = "#{heading} Updated"
            redirect "#{base_path}/#{entity.id}"
          end
          format.json do
            content_type 'application/json'
            headers 'Location' => "#{base_path}/#{entity.id}"
            body entity.to_hash.to_json
            status 200
          end
        end
      else
        respond_to do |format|
          format.html do
            haml :"#{view_location}/edit", locals: { entity: entity, title: heading(:edit) }
          end
        end
      end
    end

    delete '/:id' do |id|
      entity = dataset[id.to_i]
      halt 404 unless entity
      authorize entity, :delete

      entity.destroy

      log_action("#{dehumanized}_delete".to_sym) if settings.track_actions
      respond_to do |format|
        format.html do
          flash[:success] = "#{heading} Deleted"
          redirect base_path.to_s
        end
        format.json do
          content_type 'application/json'
          headers 'Location' => '/_proxes/users'
          status 204
        end
      end
    end
  end
end

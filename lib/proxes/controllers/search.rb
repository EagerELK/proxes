# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'ditty/controllers/application_controller'
require 'proxes/services/search'
require 'proxes/policies/search_policy'

module ProxES
  class Search < Ditty::ApplicationController
    set base_path: "#{settings.map_path}/search"
    set view_folder: ::Ditty::ProxES.view_folder

    def search_service
      ProxES::Services::Search.new(user: current_user)
    end

    helpers do
      def fields(indices, names_only)
        standard = { '_index' => 'text', '_type' => 'text', '_id' => 'text' }
        standard.merge search_service.fields(index: indices, names_only: names_only)
      end
    end

    get '/' do
      authorize self, :list

      param :page, Integer, min: 0, default: 1
      param :count, Integer, min: 0, default: 25
      from = ((params[:page] - 1) * params[:count])
      params[:q] = '*' if params[:q].blank?
      result = search_service.search(params[:q], index: params[:indices], from: from, size: params[:count])
      haml :"#{view_location}/index",
           locals: {
             title: 'Search',
             indices: search_service.indices,
             fields: fields(params[:indices], true),
             result: result
           }
    end

    get '/fields/?:indices?/?' do
      param :names_only, Boolean, default: false
      authorize self, :fields

      json fields(params[:indices], params[:names_only])
    end

    get '/indices/?' do
      authorize self, :indices

      json search_service.indices
    end

    get '/values/:field/?:indices?/?' do |field|
      authorize self, :values

      param :size, Integer, min: 0, default: 25
      json search_service.values(field, size: params[:size], index: params[:indices])
    end
  end
end

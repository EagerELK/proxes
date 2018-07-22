# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'ditty/controllers/application'
require 'proxes/services/search'
require 'proxes/policies/search_policy'

module ProxES
  class Search < Ditty::Application
    set base_path: "#{settings.map_path}/search"

    get '/' do
      authorize self, :search

      param :page, Integer, min: 0, default: 1
      param :count, Integer, min: 0, default: 25
      from = ((page - 1) * size)
      params[:q] = '*' if params[:q].blank?
      result = ProxES::Services::Search.search(params[:q], index: params[:indices], from: from, size: size)
      haml :"#{view_location}/index",
           locals: {
             title: 'Search',
             indices: ProxES::Services::Search.indices,
             fields: ProxES::Services::Search.fields(index: params[:indices], names_only: true),
             result: result
           }
    end

    get '/fields/?:indices?/?' do
      authorize self, :fields

      param :names_only, Boolean, default: false
      json ProxES::Services::Search.fields index: params[:indices], names_only: params[:names_only]
    end

    get '/indices/?' do
      authorize self, :indices

      json ProxES::Services::Search.indices
    end

    get '/values/:field/?:indices?/?' do |field|
      authorize self, :values

      param :size, Integer, min: 0, default: 25
      json ProxES::Services::Search.values(field, size: params[:size], index: params[:indices])
    end

    def find_template(views, name, engine, &block)
      super(views, name, engine, &block) # Root
      super(::Ditty::ProxES.view_folder, name, engine, &block) # This Component
      super(::Ditty::App.view_folder, name, engine, &block) # Ditty
    end
  end
end

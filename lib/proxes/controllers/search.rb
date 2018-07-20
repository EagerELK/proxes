# frozen_string_literal: true

require 'ditty/controllers/application'
require 'proxes/services/search'

module ProxES
  class Search < Ditty::Application
    set base_path: "#{settings.map_path}/search"

    get '/' do
      result = ProxES::Services::Search.search(params['q'], index: params['indices']) if params['q']
      haml :"#{view_location}/index",
           locals: {
             title: 'Search',
             indices: ProxES::Services::Search.indices,
             fields: ProxES::Services::Search.fields(params['indices']),
             result: result
           }
    end

    get '/fields/?:indices?/?' do
      json ProxES::Services::Search.fields params['indices']
    end

    get '/indices/?' do
      json ProxES::Services::Search.indices
    end

    get '/values/:field/?:indices?/?' do |field|
      size = params['size'] || 25
      json ProxES::Services::Search.values(field, size: size, index: params['indices'])
    end

    def find_template(views, name, engine, &block)
      super(views, name, engine, &block) # Root
      super(::Ditty::ProxES.view_folder, name, engine, &block) # This Component
      super(::Ditty::App.view_folder, name, engine, &block) # Ditty
    end
  end
end

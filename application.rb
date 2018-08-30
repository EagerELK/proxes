# frozen_string_literal: true

require 'ditty/components/app'
require 'ditty/components/proxes'

Ditty.component(:app)
Ditty.component(:proxes)

require 'ditty/controllers/application'
Ditty::Application.set :map_path, '/_proxes'

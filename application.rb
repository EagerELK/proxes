# frozen_string_literal: true

require 'ditty/components/ditty'
require 'ditty/components/proxes'

Ditty.component(:ditty)
Ditty.component(:proxes)

require 'ditty/controllers/application_controller'
Ditty::ApplicationController.set :map_path, '/_proxes'

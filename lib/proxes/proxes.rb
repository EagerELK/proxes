# frozen_string_literal: true
require 'proxes'

module ProxES
  class ProxES
    def self.migration_folder
      File.expand_path('../../../migrate', __FILE__)
    end
  end
end

ProxES::Container::Plugins.register_plugin(:proxes, ProxES::ProxES)

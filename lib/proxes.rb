# frozen_string_literal: true
require 'proxes/version'
require 'proxes/container'
require 'proxes/db'
require 'proxes/app'
require 'proxes/listener'

require 'proxes/proxes'
ProxES::Container.plugin(:proxes)

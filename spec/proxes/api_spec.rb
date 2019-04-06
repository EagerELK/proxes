# frozen_string_literal: true

require 'spec_helper'
Dir.glob('./lib/proxes/controllers/*.rb').each { |f| require f }
require 'support/api_shared_examples'
require 'active_support/hash_with_indifferent_access'

describe ProxES::Permissions, type: :controller do
  def app
    described_class
  end

  let(:user) { create(:super_admin_user) }

  before do
    env 'rack.session', ActiveSupport::HashWithIndifferentAccess.new('user_id' => user.id)
  end

  it_behaves_like 'an API interface', :permission, {}
end

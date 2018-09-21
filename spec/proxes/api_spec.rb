# frozen_string_literal: true

require 'spec_helper'
Dir.glob('./lib/proxes/controllers/*.rb').each { |f| require f }
require 'support/api_shared_examples'

describe ProxES::Permissions, type: :controller do
  def app
    described_class
  end

  let(:user) { create(:super_admin_user) }

  before do
    env 'rack.session', 'user_id' => user.id
  end

  it_behaves_like 'an API interface', :permission, {}
end

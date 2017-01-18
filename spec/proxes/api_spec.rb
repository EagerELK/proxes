# frozen_string_literal: true
require 'spec_helper'
Dir.glob('./lib/proxes/controllers/*.rb').each { |f| require f }
require 'support/api_shared_examples'

{
    user: ProxES::Users,
    role: ProxES::Roles,
    permission: ProxES::Permissions,
}.each do |subject, controller|
  describe controller, type: :controller do
    def app
      described_class.new(proc { [200, {}, ['Hello, world.']] })
    end

    let(:user) { create(:super_admin_user) }

    before(:each) do
      warden = double(Warden::Proxy)
      allow(warden).to receive(:user).and_return(user)
      allow(warden).to receive(:authenticate!)
      env 'warden', warden
    end

    it_behaves_like 'has API interface', subject
  end
end

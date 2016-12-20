# frozen_string_literal: true
require 'spec_helper'
require 'proxes/controllers/users'
require 'support/crud_shared_examples'

describe ProxES::Users do
  def app
    described_class
  end

  context 'as super_admin_user' do
    let(:user) { create(:super_admin_user) }
    let(:model) { create(app.model_class.name.to_sym) }
    let(:create_data) do
      group = described_class.model_class.to_s.demodulize.underscore
      identity = build(:identity).to_hash
      identity['password_confirmation'] = identity['password'] = 'som3Password!'
      {
        group => build(described_class.model_class.name.to_sym).to_hash,
        'identity' => identity
      }
    end
    let(:update_data) do
      group = described_class.model_class.to_s.demodulize.underscore
      { group => build(described_class.model_class.name.to_sym).to_hash }
    end
    let(:invalid_create_data) do
      group = described_class.model_class.to_s.demodulize.underscore
      { group => { email: 'invalidemail' } }
    end
    let(:invalid_update_data) do
      group = described_class.model_class.to_s.demodulize.underscore
      { group => { email: 'invalidemail' } }
    end

    before(:each) do
      # Log in
      warden = double(Warden::Proxy)
      allow(warden).to receive(:user).and_return(user)
      env 'warden', warden
    end

    it_behaves_like 'a CRUD Controller', '/users'
  end

  context 'as user' do
    let(:user) { create(:user) }
    let(:model) { create(app.model_class.name.to_sym) }
    let(:create_data) do
      group = described_class.model_class.to_s.demodulize.underscore
      { group => build(described_class.model_class.name.to_sym).to_hash }
    end
    let(:update_data) do
      group = described_class.model_class.to_s.demodulize.underscore
      { group => build(described_class.model_class.name.to_sym).to_hash }
    end
    let(:invalid_create_data) do
      group = described_class.model_class.to_s.demodulize.underscore
      { group => { email: 'invalidemail' } }
    end
    let(:invalid_update_data) do
      group = described_class.model_class.to_s.demodulize.underscore
      { group => { email: 'invalidemail' } }
    end

    before(:each) do
      # Log in
      warden = double(Warden::Proxy)
      allow(warden).to receive(:user).and_return(user)
      env 'warden', warden
    end

    it_behaves_like 'a CRUD Controller', '/users'
  end
end

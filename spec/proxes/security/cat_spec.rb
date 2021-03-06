# frozen_string_literal: true

require 'spec_helper'
require 'proxes/forwarder'
require 'proxes/models/permission'
require 'elasticsearch'
require 'csv'
require 'active_support/hash_with_indifferent_access'

describe ProxES do
  def app
    ProxES::Forwarder.instance
  end

  def client
    @client ||= Elasticsearch::Client.new url: ENV['ELASTICSEARCH_URL'], log: true
  end

  def get_env(request)
    meth, path = request.split(' ')
    {
      'REQUEST_METHOD' => meth,
      'PATH_INFO' => path,
      'REQUEST_PATH' => path,
      'REQUEST_URI' => path
    }
  end

  def get_fixture(name)
    fix_path = './spec/fixtures'
    File.read("#{fix_path}/#{name}")
  end

  def last_indices
    response = JSON.parse last_response.body
    response.map { |e| e['index'] }
  end

  before(:all) do
    client.index index: 'test-user-today', type: 'test', id: 1, body: { 'test': 'doc' }
    client.index index: 'test-user-yesterday', type: 'test', id: 1, body: { 'test': 'doc' }
    client.index index: 'another-user-today', type: 'test', id: 1, body: { 'test': 'doc' }
    client.index index: 'another-user-yesterday', type: 'test', id: 1, body: { 'test': 'doc' }
    client.indices.refresh index: 'test-user-today,test-user-yesterday,another-user-today,another-user-yesterday'
  end

  let(:user) { create(:user) }

  context '/_cat/indices' do
    context 'user with access' do
      before do
        ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/_cat/indices', index: 'test-user-*')
        env 'rack.session', ActiveSupport::HashWithIndifferentAccess.new('user_id' => user.id)
      end

      it 'succeeds with no indices specified' do
        get('/_cat/indices?v&format=json', {}, get_env('GET /_cat/indices?v&format=json'))
        expect(last_response).to be_ok
        expect(last_indices).to include('test-user-yesterday', 'test-user-today')
      end

      it 'succeeds with indices the user has access to' do
        get('/_cat/indices?v&format=json', {}, get_env('GET /_cat/indices/test-user-*?v&format=json'))
        expect(last_response).to be_ok
        expect(last_indices).to include('test-user-yesterday', 'test-user-today')
      end

      it 'fails with an invalid call if any of the specified indices are unauthorized' do
        expect do
          get('/_cat/indices?v=1', {}, get_env('GET /_cat/indices/other-user-*?v=1'))
        end.to raise_error Pundit::NotAuthorizedError
      end
    end

    context 'user without access' do
      before do
        env 'rack.session', ActiveSupport::HashWithIndifferentAccess.new('user_id' => user.id)
      end

      it 'fails with an invalid call for specified indices' do
        expect do
          get('/_cat/indices?v=1', {}, get_env('GET /_cat/indices?v=1'))
        end.to raise_error Pundit::NotAuthorizedError
      end

      it 'fails with an invalid for unspecified indices' do
        expect do
          get('/_cat/indices?v=1', {}, get_env('GET /_cat/indices?v=1'))
        end.to raise_error Pundit::NotAuthorizedError
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'proxes/middleware/security'
require 'proxes/forwarder'
require 'proxes/models/permission'
require 'elasticsearch'

describe ProxES::Middleware::Security do
  def app
    ProxES::Middleware::Security.new(ProxES::Forwarder.instance)
  end

  def client
    @client ||= Elasticsearch::Client.new url: ENV['ELASTICSEARCH_URL']
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

  def last_indices
    response = JSON.parse last_response.body
    response['hits']['hits'].map { |i| i['_index'] } .uniq
  end

  before(:all) do
    client.index index: 'test-user-today', type: 'test', id: 1, body: { 'test': 'doc' }
    client.index index: 'test-user-yesterday', type: 'test', id: 1, body: { 'test': 'doc' }
    client.index index: 'another-user-today', type: 'test', id: 1, body: { 'test': 'doc' }
    client.index index: 'another-user-yesterday', type: 'test', id: 1, body: { 'test': 'doc' }
    client.indices.refresh index: 'test-user-today,test-user-yesterday,another-user-today,another-user-yesterday'
  end

  let(:user) { create(:user) }

  context '/_search' do
    context 'user with access' do
      before(:each) do
        ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/*/?_search', index: 'test-user-*')
        env 'rack.session', 'user_id' => user.id
      end

      it 'succeeds with only the authorized indices if no index is specified' do
        get('/_search', {}, get_env('GET /_search'))
        expect(last_response).to be_ok
        expect(last_indices).to include('test-user-today', 'test-user-yesterday')
        expect(last_indices).to_not include('another-user-today', 'another-user-yesterday')
      end

      it 'succeeds with only the specified indices if they are authorized' do
        get(
          '/test-user-today,test-user-yesterday/_search',
          {},
          get_env('GET /test-user-today,test-user-yesterday/_search')
        )
        expect(last_response).to be_ok
        expect(last_indices).to eq ['test-user-today', 'test-user-yesterday']
      end

      it 'fails with an invalid call if some specified indices are unauthorized' do
        expect do
          get(
            '/test-user-today,another-user-today/_search',
            {},
            get_env('GET /test-user-today,another-user-today/_search')
          )
        end.to raise_error Pundit::NotAuthorizedError
      end

      it 'fails with an invalid call if all of the specified indices are unauthorized' do
        expect do
          get(
            '/another-user-today,another-user-yesterday/_search',
            {},
            get_env('GET /another-user-today,another-user-yesterday/_search')
          )
        end.to raise_error Pundit::NotAuthorizedError
      end
    end

    context 'user without access' do
      before(:each) do
        env 'rack.session', 'user_id' => user.id
      end

      it 'fails with specified indices' do
        expect do
          get(
            '/test-user-today,another-user-yesterday/_search',
            {},
            get_env('GET /test-user-today,another-user-yesterday/_search')
          )
        end.to raise_error Pundit::NotAuthorizedError
      end

      it 'fails without specified indices' do
        expect { get('/_search', {}, get_env('GET /_search')) }.to raise_error Pundit::NotAuthorizedError
      end
    end
  end
end

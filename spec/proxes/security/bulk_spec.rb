# frozen_string_literal: true

require 'spec_helper'
require 'proxes/security'
require 'proxes/forwarder'
require 'proxes/models/permission'
require 'elasticsearch'

describe ProxES do
  def app
    ProxES::Security.new(ProxES::Forwarder.new(backend: ENV['ELASTICSEARCH_URL']))
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

  context '/_bulk' do
    context 'user with access' do
      before(:each) do
        ProxES::Permission.find_or_create(user: user, verb: 'POST', pattern: '/_bulk')
        ProxES::Permission.find_or_create(user: user, verb: 'INDEX', pattern: 'test-user-*')
        env 'rack.session', 'user_id' => user.id
      end

      it 'succeeds with indices the user has access to' do
        post('/_bulk', get_fixture('legal_bulk_with_indices.json'), get_env('POST /_bulk'))
        expect(last_response).to be_ok
      end

      it 'fails with an invalid call if any of the specified indices are unauthorized' do
        post('/_bulk', get_fixture('illegal_bulk_with_indices.json'), get_env('POST /_bulk'))
        expect(last_response).to_not be_ok
        expect(last_response.status).to eq(401)
      end
    end

    context 'user without INDEX access' do
      before(:each) do
        ProxES::Permission.find_or_create(user: user, verb: 'POST', pattern: '/_bulk')
        env 'rack.session', 'user_id' => user.id
      end

      it 'fails with an invalid for specified indices' do
        post('/_bulk', get_fixture('bulk_without_indices.json'), get_env('POST /test-user-today/_bulk'))
        expect(last_response).to_not be_ok
        expect(last_response.status).to eq(401)
      end

      it 'fails with an invalid for unspecified indices' do
        post('/_bulk', get_fixture('illegal_bulk_with_indices.json'), get_env('POST /_bulk'))
        expect(last_response).to_not be_ok
        expect(last_response.status).to eq(401)
      end
    end

    context 'user without access' do
      before(:each) do
        env 'rack.session', 'user_id' => user.id
      end

      it 'fails with an invalid for specified indices' do
        post('/_bulk', get_fixture('bulk_without_indices.json'), get_env('POST /test-user-today/_bulk'))
        expect(last_response).to_not be_ok
        expect(last_response.status).to eq(401)
      end

      it 'fails with an invalid for unspecified indices' do
        post('/_bulk', get_fixture('illegal_bulk_with_indices.json'), get_env('POST /_bulk'))
        expect(last_response).to_not be_ok
        expect(last_response.status).to eq(401)
      end
    end
  end

  context '/{index}/_bulk' do
    context 'user with access' do
      before(:each) do
        ProxES::Permission.find_or_create(user: user, verb: 'POST', pattern: '/_bulk')
        ProxES::Permission.find_or_create(user: user, verb: 'INDEX', pattern: 'test-user-*')
        env 'rack.session', 'user_id' => user.id
      end

      it 'succeeds with indices the user has access to' do
        post('/test-user-today/_bulk', get_fixture('legal_bulk_with_indices.json'), get_env('POST /test-user-today/_bulk'))
        expect(last_response).to be_ok
      end

      it 'fails with an invalid call if any of the specified indices are unauthorized' do
        post('/test-user-today/_bulk', get_fixture('illegal_bulk_with_indices.json'), get_env('POST /test-user-today/_bulk'))
        expect(last_response).to_not be_ok
        expect(last_response.status).to eq(401)
      end

      it 'succeeds with indices the user has access to in the URL' do
        post('/test-user-today/_bulk', get_fixture('bulk_without_indices.json'), get_env('POST /test-user-today/_bulk'))
        expect(last_response).to be_ok
      end

      it 'fails with an invalid call if any of the specified indices in the URL are unauthorized' do
        post('/another-user-today/_bulk', get_fixture('bulk_without_indices.json'), get_env('POST /another-user-today/_bulk'))
        expect(last_response).to_not be_ok
        expect(last_response.status).to eq(401)
      end
    end

    context 'user without access' do
      before(:each) do
        env 'rack.session', 'user_id' => user.id
      end
    end
  end
end

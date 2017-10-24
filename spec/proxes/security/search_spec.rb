# frozen_string_literal: true

require 'spec_helper'
require 'proxes/security'
require 'proxes/forwarder'
require 'proxes/models/permission'

describe ProxES do
  def app
    ProxES::Security.new(ProxES::Forwarder.new(backend: ENV['ELASTICSEARCH_URL']))
  end

  #get_env('GET /_search')
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
    response['hits']['hits'].map{ |i| i['_index']}.uniq
  end

  context 'user with access' do
    let(:user) { create(:user) }

    before(:each) do
      ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/_search')
      ProxES::Permission.find_or_create(user: user, verb: 'INDEX', pattern: 'test-user-*')
      env 'rack.session', 'user_id' => user.id
    end

    fit 'succeeds with only the authorized indices if no index is specified' do
      get('/_search')
      expect(last_response).to be_ok
      expect(last_indices).to include('test-user-today')
    end

    it 'succeeds with only the specified indices if they are authorized'
    it 'succeeds with only the authorized indices if some specified indices are unauthorized'
    it 'fails with a not found if all of the specified indices are unauthorized'
  end

  context 'user without access' do
  end

  context '/my-index/_search' do
    it 'allows'
  end
end

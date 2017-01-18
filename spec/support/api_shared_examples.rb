# frozen_string_literal: true
require 'json'

shared_examples 'has API interface' do |subject|
  context 'GET /' do
    it 'returns HTML when requested' do
      get '/', { 'Accept' => 'text/html' }

      expect(last_response).to be_ok
      expect(last_response.headers).to include('Content-Type' => 'text/html;charset=utf-8')
    end

    it 'returns JSON when requested' do
      get '/', { 'Accept' => 'application/json' }

      expect(last_response).to be_ok
      expect(last_response.headers).to include('Content-Type' => 'application/json')
      expect{JSON.parse(last_response.body)}.to_not raise_error
    end

    it 'returns a list object' do
      get '/', { 'Accept' => 'application/json' }

      response = JSON.parse last_response.body
      expect(response).to include('page', 'count', 'total', 'items')
      expect(response['page']).to be_an_instance_of Fixnum
      expect(response['count']).to be_an_instance_of Fixnum
      expect(response['total']).to be_an_instance_of Fixnum
      expect(response['items']).to be_an Array
    end
  end

  context 'GET /id' do
    let(:entity) { create(subject) }

    it 'returns HTML when requested' do
      get "/#{entity.id}", { 'Accept' => 'text/html' }

      expect(last_response).to be_ok
      expect(last_response.headers).to include('Content-Type' => 'text/html;charset=utf-8')
    end

    it 'returns JSON when requested' do
      get "/#{entity.id}", { 'Accept' => 'application/json' }

      expect(last_response).to be_ok
      expect(last_response.headers).to include('Content-Type' => 'application/json')
      expect{JSON.parse(last_response.body)}.to_not raise_error
    end

    it 'returns the fetched object' do
      get "/#{entity.id}", { 'Accept' => 'application/json' }

      response = JSON.parse last_response.body
      expect(response).to be_a Hash
      entity_to_json = JSON.parse entity.values.to_json
      expect(response).to include(entity_to_json)
    end
  end

  context 'POST /' do
  end
end

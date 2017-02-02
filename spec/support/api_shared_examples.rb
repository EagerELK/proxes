# frozen_string_literal: true
require 'json'

shared_examples 'an API interface' do |subject, params|
  context 'GET /' do
    it 'returns HTML when requested' do
      get '/', 'Accept' => 'text/html'

      expect(last_response).to be_ok
      expect(last_response.headers).to include('Content-Type' => 'text/html;charset=utf-8')
    end

    it 'returns JSON when requested' do
      header 'Accept', 'application/json'
      get '/'

      expect(last_response).to be_ok
      expect(last_response.headers).to include('Content-Type' => 'application/json')
      expect { JSON.parse(last_response.body) }.to_not raise_error
    end

    it 'returns a list object' do
      header 'Accept', 'application/json'
      get '/'

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
      header 'Accept', 'text/html'
      get "/#{entity.id}"

      expect(last_response).to be_ok
      expect(last_response.headers).to include('Content-Type' => 'text/html;charset=utf-8')
    end

    it 'returns JSON when requested' do
      header 'Accept', 'application/json'
      get "/#{entity.id}"

      expect(last_response).to be_ok
      expect(last_response.headers).to include('Content-Type' => 'application/json')
      expect { JSON.parse(last_response.body) }.to_not raise_error
    end

    it 'returns the fetched object' do
      header 'Accept', 'application/json'
      get "/#{entity.id}"

      response = JSON.parse last_response.body
      expect(response).to be_a Hash
      entity_to_json = JSON.parse entity.values.to_json
      expect(response).to include(entity_to_json)
    end
  end

  context 'POST /' do
    it 'returns HTML when requested' do
      header 'Accept', 'text/html'
      header 'Content-Type', 'application/x-www-form-urlencoded'
      params[subject] = build(subject).to_hash
      post '/', params

      expect(last_response.headers).to include('Content-Type' => 'text/html;charset=utf-8')
    end

    it 'returns a 302 Created response for a HTML Request' do
      header 'Accept', 'text/html'
      header 'Content-Type', 'application/x-www-form-urlencoded'
      params[subject] = build(subject).to_hash
      post '/', params

      expect(last_response.status).to eq 302
    end

    it 'returns JSON when requested' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      params[subject] = build(subject).to_hash
      post '/', params.to_json

      expect(last_response.headers).to include('Content-Type' => 'application/json')
    end

    it 'returns a 201 Created response for a JSON Request' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      params[subject] = build(subject).to_hash
      post '/', params.to_json

      expect(last_response.status).to eq 201
    end

    it 'returns a Location Header for a JSON Request' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      params[subject] = build(subject).to_hash
      post '/', params.to_json

      expect(last_response.headers).to include 'Location'
    end

    it 'returns an empty body for a JSON Request' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      params[subject] = build(subject).to_hash
      post '/', params.to_json

      expect(last_response.body).to eq ''
    end
  end
end

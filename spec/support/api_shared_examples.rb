# frozen_string_literal: true

require 'json'
require 'active_support/core_ext/hash/except'

shared_examples 'an API interface' do |subject, params|
  before(:each) { create(subject) }

  context 'GET /' do
    it 'returns HTML when requested' do
      header 'Accept', 'text/html'
      get '/'

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

    it 'returns a 302 Redirect response for a HTML Request' do
      header 'Accept', 'text/html'
      header 'Content-Type', 'application/x-www-form-urlencoded'
      params[subject] = build(subject).to_hash
      post '/', params

      expect(last_response.status).to eq 302
      expect(last_response.headers).to include('Location')
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

  context 'PUT /:id' do
    let(:entity) { create(subject) }

    it 'returns HTML when requested' do
      header 'Accept', 'text/html'
      header 'Content-Type', 'application/x-www-form-urlencoded'

      values = entity.to_hash.except(:id)
      params[subject] = values
      put "/#{entity.id}", params

      expect(last_response.headers).to include('Content-Type' => 'text/html;charset=utf-8')
    end

    it 'returns a 302 Redirect response for a HTML Request' do
      header 'Accept', 'text/html'
      header 'Content-Type', 'application/x-www-form-urlencoded'

      values = entity.to_hash.except(:id)
      params[subject] = values
      put "/#{entity.id}", params

      expect(last_response.status).to eq 302
      expect(last_response.headers).to include('Location')
    end

    it 'returns JSON when requested' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'

      values = entity.to_hash.except(:id)
      params[subject] = values
      put "/#{entity.id}", params.to_json

      expect(last_response.headers).to include('Content-Type' => 'application/json')
    end

    it 'returns a 200 OK response for a JSON Request' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'

      values = entity.to_hash.except(:id)
      params[subject] = values
      put "/#{entity.id}", params.to_json

      expect(last_response.status).to eq 200
    end

    it 'returns a Location Header for a JSON Request' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'

      values = entity.to_hash.except(:id)
      params[subject] = values
      put "/#{entity.id}", params.to_json

      expect(last_response.headers).to include 'Location'
    end

    it 'returns the updated entity in the body for a JSON Request' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'

      values = entity.to_hash.except(:id)
      params[subject] = values
      put "/#{entity.id}", params.to_json

      response = JSON.parse last_response.body
      entity_to_hash = JSON.parse entity.values.to_json
      expect(response).to eq entity_to_hash
    end
  end

  context 'DELETE /:id' do
    let(:entity) { create(subject) }

    it 'returns HTML when requested' do
      header 'Accept', 'text/html'
      header 'Content-Type', 'application/x-www-form-urlencoded'

      delete "/#{entity.id}"

      expect(last_response.headers).to include('Content-Type' => 'text/html;charset=utf-8')
    end

    it 'returns a 302 Redirect response for a HTML Request' do
      header 'Accept', 'text/html'
      header 'Content-Type', 'application/x-www-form-urlencoded'

      delete "/#{entity.id}"

      expect(last_response.status).to eq 302
      expect(last_response.headers).to include('Location')
    end

    it 'returns JSON when requested' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'

      delete "/#{entity.id}"

      expect(last_response.headers).to include('X-Content-Type-Options' => 'nosniff')
    end

    it 'returns a 204 No Content response for a JSON Request' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'

      delete "/#{entity.id}"

      expect(last_response.status).to eq 204
    end

    it 'returns an empty body for a JSON Request' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'

      delete "/#{entity.id}"

      expect(last_response.body).to eq ''
    end
  end
end

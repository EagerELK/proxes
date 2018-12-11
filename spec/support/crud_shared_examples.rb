# frozen_string_literal: true

shared_examples 'a CRUD Controller' do |route|
  context 'GET' do
    it '/doesnotexist' do
      get '/doesnotexist'
      expect(last_response).not_to be_ok
      expect(last_response.status).to eq 404
    end

    it route.to_s do
      model # Ensure that there's at least one item in the list
      get '/'

      if Pundit.policy(user, app.model_class).list?
        expect(last_response).to be_ok, "Expected OK response, got #{last_response.status}"
      else
        expect(last_response).not_to be_ok, "Expected a NOT OK response, got #{last_response.status}"
      end
    end

    it "#{route}?count=1&page=1" do
      model # Ensure that there's at least one item in the list
      get '/?count=1&page=1'

      if Pundit.policy(user, app.model_class).list?
        expect(last_response).to be_ok, "Expected OK response, got #{last_response.status}"
      else
        expect(last_response).not_to be_ok, "Expected a NOT OK response, got #{last_response.status}"
      end
    end

    it "#{route}/new" do
      get '/new'

      if Pundit.policy(user, app.model_class).create?
        expect(last_response).to be_ok, "Expected OK response, got #{last_response.status}"
      else
        expect(last_response).not_to be_ok, "Expected a NOT OK response, got #{last_response.status}"
      end
    end

    it "#{route}/id" do
      get "/#{model.id}"

      if Pundit.policy(user, model).read?
        expect(last_response).to be_ok, "Expected OK response, got #{last_response.status}"
      else
        expect(last_response).not_to be_ok, "Expected a NOT OK response, got #{last_response.status}"
      end
    end

    it "#{route}/id/edit" do
      get "/#{model.id}/edit"

      if Pundit.policy(user, model).update?
        expect(last_response).to be_ok, "Expected OK response, got #{last_response.status}"
      else
        expect(last_response).not_to be_ok, "Expected a NOT OK response, got #{last_response.status}"
      end
    end
  end

  context 'POST' do
    it '/doesnotexist' do
      header 'Accept', 'text/html'
      post '/doesnotexist'
      expect(last_response).not_to be_ok, "Expected a NOT OK response, got #{last_response.status}"
      expect(last_response.status).to eq 404
    end

    it route.to_s do
      header 'Accept', 'text/html'
      post '/', create_data

      if Pundit.policy(user, app.model_class).create?
        expect(last_response.status).to eq 302
      else
        expect(last_response).not_to be_ok, "Expected a NOT OK response, got #{last_response.status}"
      end
    end

    it "#{route} with invalid parameters" do
      header 'Accept', 'text/html'
      header 'Content-Type', 'application/x-www-form-urlencoded'
      post '/', invalid_create_data

      if Pundit.policy(user, app.model_class).create?
        expect(last_response.status).to eq 400
      else
        expect(last_response).not_to be_ok, "Expected a NOT OK response, got #{last_response.status}"
      end
    end
  end

  context 'PUT' do
    it '/doesnotexist' do
      header 'Accept', 'text/html'
      put '/doesnotexist'
      expect(last_response).not_to be_ok, "Expected a NOT OK response, got #{last_response.status}"
      expect(last_response.status).to eq 404
    end

    it "#{route}/:id" do
      header 'Accept', 'text/html'
      put "/#{model.id}", update_data

      if Pundit.policy(user, model).update?
        expect(last_response.status).to eq 302
      else
        expect(last_response).not_to be_ok, "Expected a NOT OK response, got #{last_response.status}"
      end
    end

    it "#{route} with invalid parameters" do
      header 'Accept', 'text/html'
      put "/#{model.id}", invalid_update_data

      if Pundit.policy(user, model).update?
        expect(last_response.status).to eq 400
      else
        expect(last_response).not_to be_ok, "Expected a NOT OK response, got #{last_response.status}"
      end
    end
  end

  context 'DELETE' do
    it '/doesnotexist' do
      delete '/doesnotexist'
      expect(last_response).not_to be_ok, "Expected a NOT OK response, got #{last_response.status}"
      expect(last_response.status).to eq 404
    end

    it "#{route}/id" do
      header 'Accept', 'text/html'
      delete "/#{model.id}"

      if Pundit.policy(user, model).delete?
        expect(last_response.status).to eq 302
      else
        expect(last_response).not_to be_ok
      end
    end
  end
end

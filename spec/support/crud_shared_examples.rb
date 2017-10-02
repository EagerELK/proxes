# frozen_string_literal: true

shared_examples 'a CRUD Controller' do |route|
  context 'GET' do
    it '/doesnotexist' do
      get '/doesnotexist'
      expect(last_response).to_not be_ok
      expect(last_response.status).to eq 404
    end

    it route.to_s do
      model # Ensure that there's at least one item in the list
      get '/'

      if Pundit.policy(user, app.model_class).list?
        expect(last_response).to be_ok
      else
        expect(last_response).to_not be_ok
      end
    end

    it "#{route}?count=1&page=1" do
      model # Ensure that there's at least one item in the list
      get '/?count=1&page=1'

      if Pundit.policy(user, app.model_class).list?
        expect(last_response).to be_ok
      else
        expect(last_response).to_not be_ok
      end
    end

    it "#{route}/new" do
      get '/new'

      if Pundit.policy(user, app.model_class).list?
        expect(last_response).to be_ok
      else
        expect(last_response).to_not be_ok
      end
    end

    it "#{route}/id" do
      get "/#{model.id}"

      if Pundit.policy(user, app.model_class).list?
        expect(last_response).to be_ok
      else
        expect(last_response).to_not be_ok
      end
    end

    it "#{route}/id/edit" do
      get "/#{model.id}/edit"

      if Pundit.policy(user, app.model_class).list?
        expect(last_response).to be_ok
      else
        expect(last_response).to_not be_ok
      end
    end
  end

  context 'POST' do
    it '/doesnotexist' do
      post '/doesnotexist'
      expect(last_response).to_not be_ok
      expect(last_response.status).to eq 404
    end

    it route.to_s do
      post '/', create_data

      if Pundit.policy(user, app.model_class).list?
        expect(last_response.status).to eq 302
      else
        expect(last_response).to_not be_ok
      end
    end

    it "#{route} with invalid parameters" do
      post '/', invalid_create_data

      if Pundit.policy(user, app.model_class).list?
        expect(last_response).to be_ok # A 200 is given since it just re-renders the form
      else
        expect(last_response).to_not be_ok
      end
    end
  end

  context 'PUT' do
    it '/doesnotexist' do
      put '/doesnotexist'
      expect(last_response).to_not be_ok
      expect(last_response.status).to eq 404
    end

    it "#{route}/:id" do
      put "/#{model.id}", update_data

      if Pundit.policy(user, app.model_class).list?
        expect(last_response.status).to eq 302
      else
        expect(last_response).to_not be_ok
      end
    end

    it "#{route} with invalid parameters" do
      put "/#{model.id}", invalid_update_data

      if Pundit.policy(user, app.model_class).list?
        expect(last_response).to be_ok # A 200 is given since it just re-renders the form
      else
        expect(last_response).to_not be_ok
      end
    end
  end

  context 'DELETE' do
    it '/doesnotexist' do
      delete '/doesnotexist'
      expect(last_response).to_not be_ok
      expect(last_response.status).to eq 404
    end

    it "#{route}/id" do
      delete "/#{model.id}"

      if Pundit.policy(user, app.model_class).list?
        expect(last_response.status).to eq 302
      else
        expect(last_response).to_not be_ok
      end
    end
  end
end

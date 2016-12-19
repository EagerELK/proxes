# frozen_string_literal: true
shared_examples 'a CRUD Controller' do |route|
  context 'GET' do
    it route.to_s do
      model # Ensure that there's at least one item in the list
      get '/'

      if Pundit.policy(user, app.model_class).list?
        expect(last_response).to be_ok
      else
        expect(last_response).to_not be_ok
      end
    end

    it "#{route}/new" do
      get '/'

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
      get "/#{model.id}"

      if Pundit.policy(user, app.model_class).list?
        expect(last_response).to be_ok
      else
        expect(last_response).to_not be_ok
      end
    end
  end
end

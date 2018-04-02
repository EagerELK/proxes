# frozen_string_literal: true

require 'spec_helper'
require 'proxes/middleware/security'

describe ProxES::Middleware::Security do
  def app
    ProxES::Middleware::Security.new(proc { [200, {}, ['Hello, world.']] })
  end

  context '#call' do
    it 'rejects anonymous requests' do
      expect { get('/') }.to raise_error Pundit::NotAuthorizedError
      expect { get('/_search') }.to raise_error Pundit::NotAuthorizedError
      expect { get('/index/_search') }.to raise_error Pundit::NotAuthorizedError
      expect { get('/_node') }.to raise_error Pundit::NotAuthorizedError
      expect { get('/_cluster') }.to raise_error Pundit::NotAuthorizedError
      expect { get('/_snapshot') }.to raise_error Pundit::NotAuthorizedError
    end

    context 'logged in' do
      context 'normal user' do
        let(:user) { create(:user) }

        before(:each) do
          # Log in
          env 'rack.session', 'user_id' => user.id
        end

        it 'authorizes calls that return data' do
          expect { get '/notmyindex/_search' }.to raise_error Pundit::NotAuthorizedError
        end

        it 'authorizes calls that do actions' do
          expect { get '/' }.to raise_error Pundit::NotAuthorizedError

          expect { get '/_snapshot' }.to raise_error Pundit::NotAuthorizedError
        end
      end

      context 'super user' do
        let(:user) { create(:super_admin_user) }

        before(:each) do
          # Log in
          env 'rack.session', 'user_id' => user.id
        end

        it 'authorizes calls that return data' do
          expect { get('/notmyindex/_search')  }.to_not raise_error
        end

        it 'authorizes calls that do actions' do
          expect { get('/') }.to_not raise_error
          expect(last_response.status).to eq 200
          expect { get('/_node') }.to_not raise_error
          expect(last_response.status).to eq 200
          expect { get('/_cluster') }.to_not raise_error
          expect(last_response.status).to eq 200
          expect { get('/_snapshot') }.to_not raise_error
          expect(last_response.status).to eq 200
        end
      end
    end
  end
end

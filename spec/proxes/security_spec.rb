# frozen_string_literal: true

require 'spec_helper'
require 'proxes/security'

describe ProxES::Security do
  def app
    ProxES::Security.new(proc { [200, {}, ['Hello, world.']] })
  end

  context '#call' do
    it 'rejects anonymous requests' do
      get('/')
      expect(last_response).to_not be_ok
      expect(last_response.status).to eq 401
      get('/_search')
      expect(last_response).to_not be_ok
      expect(last_response.status).to eq 401
      get('/index/_search')
      expect(last_response).to_not be_ok
      expect(last_response.status).to eq 401
      get('/_node')
      expect(last_response).to_not be_ok
      expect(last_response.status).to eq 401
      get('/_cluster')
      expect(last_response).to_not be_ok
      expect(last_response.status).to eq 401
      get('/_snapshot')
      expect(last_response).to_not be_ok
      expect(last_response.status).to eq 401
    end

    context 'logged in' do
      context 'normal user' do
        let(:user) { create(:user) }

        before(:each) do
          # Log in
          env 'rack.session', 'user_id' => user.id
        end

        it 'authorizes calls that return data' do
          get '/notmyindex/_search'
          expect(last_response).to_not be_ok
          expect(last_response.status).to eq 401
        end

        it 'authorizes calls that do actions' do
          get '/'
          expect(last_response).to_not be_ok
          expect(last_response.status).to eq 401

          get '/_snapshot'
          expect(last_response).to_not be_ok
          expect(last_response.status).to eq 401
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
          expect { get('/_node') }.to_not raise_error
          expect { get('/_cluster') }.to_not raise_error
          expect { get('/_snapshot') }.to_not raise_error
        end
      end
    end
  end
end

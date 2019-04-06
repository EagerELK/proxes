# frozen_string_literal: true

require 'spec_helper'
require 'proxes/middleware/security'
require 'active_support/hash_with_indifferent_access'

describe ProxES::Middleware::Security do
  def app
    ProxES::Middleware::Security.new(proc { [200, {}, ['Hello, world.']] })
  end

  context '#call' do
    %w[/ /_search /index/_search /_node /_cluster /_snapshot].each do |path|
      it "rejects anonymous requests to #{path}" do
        expect { get(path) }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context 'logged in' do
      context 'normal user' do
        let(:user) { create(:user) }

        before do
          # Log in
          env 'rack.session', ActiveSupport::HashWithIndifferentAccess.new('user_id' => user.id)
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

        before do
          # Log in
          env 'rack.session', 'user_id' => user.id
        end

        it 'authorizes calls that return data' do
          expect { get('/notmyindex/_search')  }.not_to raise_error
        end

        it 'authorizes calls that do actions' do
          expect { get('/') }.not_to raise_error
          expect(last_response.status).to eq 200
          expect { get('/_node') }.not_to raise_error
          expect(last_response.status).to eq 200
          expect { get('/_cluster') }.not_to raise_error
          expect(last_response.status).to eq 200
          expect { get('/_snapshot') }.not_to raise_error
          expect(last_response.status).to eq 200
        end
      end
    end
  end
end

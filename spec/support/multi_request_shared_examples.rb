# frozen_string_literal: true

require 'json'
require 'proxes/middleware/security'
require 'proxes/forwarder'
require 'proxes/models/permission'
require 'elasticsearch'
require 'active_support/core_ext/hash/except'
require 'active_support/hash_with_indifferent_access'

shared_examples 'Multi Request' do |verb, endpoint|
  before(:all) do
    client.index index: 'test-user-today', type: 'test', id: 1, body: { 'test': 'doc' }
    client.index index: 'test-user-yesterday', type: 'test', id: 1, body: { 'test': 'doc' }
    client.index index: 'another-user-today', type: 'test', id: 1, body: { 'test': 'doc' }
    client.index index: 'another-user-yesterday', type: 'test', id: 1, body: { 'test': 'doc' }
    client.indices.refresh index: 'test-user-today,test-user-yesterday,another-user-today,another-user-yesterday'
  end

  def app
    ProxES::Middleware::Security.new(ProxES::Forwarder.instance)
  end

  def client
    @client ||= Elasticsearch::Client.new url: ENV['ELASTICSEARCH_URL'], log: true
  end

  def get_env(request)
    meth, path = request.split(' ')
    {
      'REQUEST_METHOD' => meth,
      'PATH_INFO' => path,
      'REQUEST_PATH' => path,
      'REQUEST_URI' => path
    }
  end

  def get_fixture(name)
    fix_path = './spec/fixtures'
    File.read("#{fix_path}/#{name}")
  end

  def last_indices
    response = JSON.parse last_response.body
    response['hits']['hits'].map { |i| i['_index'] } .uniq
  end

  let(:user) { create(:user) }

  context "/#{endpoint}" do
    context 'user with access' do
      before do
        ProxES::Permission.find_or_create(user: user, verb: verb, pattern: "/#{endpoint}", index: 'test-user-*')
        env 'rack.session', ActiveSupport::HashWithIndifferentAccess.new('user_id' => user.id)
      end

      it 'succeeds with indices the user has access to' do
        send(
          verb.downcase,
          endpoint,
          {},
          get_env("#{verb} /#{endpoint}").merge(
            'rack.input' => StringIO.new(get_fixture("legal#{endpoint}_with_indices.json"))
          )
        )
        expect(last_response).to be_ok
      end

      # Not ideal, but (for now) we can't filter out the illegal indices
      it 'fails with an invalid call if any of the specified indices are unauthorized' do
        expect do
          send(
            verb.downcase,
            endpoint,
            {},
            get_env("#{verb} /#{endpoint}").merge(
              'rack.input' => StringIO.new(get_fixture("illegal#{endpoint}_with_indices.json"))
            )
          )
        end.to raise_error Pundit::NotAuthorizedError
      end
    end

    context 'user without access' do
      before do
        env 'rack.session', ActiveSupport::HashWithIndifferentAccess.new('user_id' => user.id)
      end

      it 'fails with an invalid for specified indices' do
        expect do
          send(
            verb.downcase,
            endpoint,
            {},
            get_env("#{verb} /test-user-today/#{endpoint}").merge(
              'rack.input' => StringIO.new(get_fixture("multi#{endpoint}_without_indices.json"))
            )
          )
        end.to raise_error Pundit::NotAuthorizedError
      end

      it 'fails with an invalid for unspecified indices' do
        expect do
          send(
            verb.downcase,
            endpoint,
            {},
            get_env("#{verb} /#{endpoint}").merge(
              'rack.input' => StringIO.new(get_fixture("illegal#{endpoint}_with_indices.json"))
            )
          )
        end.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  context "/{index}/#{endpoint}" do
    context 'user with access' do
      before do
        ProxES::Permission.find_or_create(user: user, verb: verb, pattern: "/*/?#{endpoint}", index: 'test-user-*')
        env 'rack.session', ActiveSupport::HashWithIndifferentAccess.new('user_id' => user.id)
      end

      it 'succeeds with indices the user has access to' do
        send(
          verb.downcase,
          "/test-user-today/#{endpoint}",
          {},
          get_env("#{verb} /test-user-today/#{endpoint}").merge(
            'rack.input' => StringIO.new(get_fixture("legal#{endpoint}_with_indices.json"))
          )
        )
        expect(last_response).to be_ok
      end

      it 'fails with an invalid call if any of the specified indices are unauthorized' do
        expect do
          send(
            verb.downcase,
            "/test-user-today/#{endpoint}",
            {},
            get_env("#{verb} /test-user-today/#{endpoint}").merge(
              'rack.input' => StringIO.new(get_fixture("illegal#{endpoint}_with_indices.json"))
            )
          )
        end.to raise_error Pundit::NotAuthorizedError
      end

      it 'succeeds with indices the user has access to in the URL' do
        send(
          verb.downcase,
          "/test-user-today/#{endpoint}",
          {},
          get_env("#{verb} /test-user-today/#{endpoint}").merge(
            'rack.input' => StringIO.new(get_fixture("multi#{endpoint}_without_indices.json"))
          )
        )
        expect(last_response).to be_ok
      end

      it 'fails with an invalid call if any of the specified indices in the URL are unauthorized' do
        expect do
          send(
            verb.downcase,
            "/another-user-today/#{endpoint}",
            {},
            get_env("#{verb} /another-user-today/#{endpoint}").merge(
              'rack.input' => StringIO.new(get_fixture("multi#{endpoint}_without_indices.json"))
            )
          )
        end.to raise_error Pundit::NotAuthorizedError
      end
    end

    context 'user without access' do
      before do
        env 'rack.session', ActiveSupport::HashWithIndifferentAccess.new('user_id' => user.id)
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'proxes/policies/request_policy'
require 'proxes/request/index'

describe ProxES::RequestPolicy do
  let(:user) { create(:user) }

  def get_env(request)
    meth, path = request.split(' ')
    {
      'REQUEST_METHOD' => meth,
      'PATH_INFO' => path,
      'REQUEST_PATH' => path,
      'REQUEST_URI' => path,
      'rack.session' => { 'user_id' => user.id }
    }
  end

  context '.initialize' do
    it 'Defaults to the anonymous user if none is given' do
      subject = described_class.new(nil, Rack::Request.new({}))
      expect(subject.user.anonymous?).to be_truthy
    end
  end

  context '#method_missing' do
    it 'still throws errors on legit missing methods' do
      subject = described_class.new(nil, Rack::Request.new({}))
      expect { subject.missing }.to raise_error NoMethodError
    end

    it 'checks the set up permissions' do
      ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/*', index: 'index')

      subject = described_class.new(user, ProxES::Request::Index.new(get_env('GET /index/type/id')))
      expect(subject.get?).to be_truthy
    end

    it 'returns false if a disallowed index is requested' do
      ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/*', index: 'index')

      subject = described_class.new(user, ProxES::Request::Search.new(get_env('GET /index,another/_search')))
      expect(subject.get?).to be_falsey
    end
  end

  context '#permissions' do
    it 'checks permissions against the user and the verb' do
      other_user = create(:user)
      ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/*', index: '*')
      ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/other*', index: '*')
      ProxES::Permission.find_or_create(user: other_user, verb: 'GET', pattern: '/*', index: '*')
      ProxES::Permission.find_or_create(user: user, verb: 'POST', pattern: '/*', index: '*')

      subject = described_class.new(user, ProxES::Request::Index.new(get_env('GET /index/type/id')))
      expect(subject.permissions.count).to eq 1
    end
  end
end

describe ProxES::RequestPolicy::Scope do
  let(:user) { create(:user) }

  def get_env(request)
    meth, path = request.split(' ')
    {
      'REQUEST_METHOD' => meth,
      'PATH_INFO' => path,
      'REQUEST_PATH' => path,
      'REQUEST_URI' => path,
      'rack.session' => { 'user_id' => user.id }
    }
  end

  context '.initialize' do
    it 'Defaults to the anonymous user if none is given' do
      subject = described_class.new(nil, Rack::Request.new({}))
      expect(subject.user.anonymous?).to be_truthy
    end
  end

  context '#resolve' do
    it 'returns the matching indices' do
      ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/*', index: 'one')
      ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/*', index: 'two')

      subject = described_class.new(user, ProxES::Request::Search.new(get_env('GET /one,three/_search')))
      expect(subject.resolve).to eq ['one']
    end

    it 'returns all the specified indices if * indices are requested' do
      ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/*', index: 'one')
      ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/*', index: 'two')

      subject = described_class.new(user, ProxES::Request::Search.new(get_env('GET /*/_search')))
      expect(subject.resolve).to eq ['one', 'two']
    end

    it 'returns all the specified indices if no indices are specified' do
      ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/*', index: 'one')
      ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/*', index: 'two')

      subject = described_class.new(user, ProxES::Request::Search.new(get_env('GET /_search')))
      expect(subject.resolve).to eq ['one', 'two']
    end
  end

  context '#permissions' do
    it 'checks the set up permissions' do
      other_user = create(:user)
      ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/*', index: '*')
      ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/other*', index: '*')
      ProxES::Permission.find_or_create(user: other_user, verb: 'GET', pattern: '/*', index: '*')
      ProxES::Permission.find_or_create(user: user, verb: 'POST', pattern: '/*', index: '*')

      subject = described_class.new(user, ProxES::Request::Index.new(get_env('GET /index/type/id')))
      expect(subject.permissions.count).to eq 1
    end
  end
end

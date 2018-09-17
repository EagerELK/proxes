# frozen_string_literal: true

require 'spec_helper'
require 'proxes/request/mget'

describe ProxES::Request::Mget do
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

  context '.from_env' do
    it 'returns a MGet request' do
      expect(ProxES::Request.from_env(get_env('GET /_mget'))).to be_a(described_class)
    end

    it 'gives the endpoint as _mget' do
      expect(ProxES::Request.from_env(get_env('GET /_mget')).endpoint).to eq '_mget'
    end
  end

  context '#indices?' do
    it 'does have indices' do
      env = get_env('GET /_mget').merge('rack.input' => StringIO.new(get_fixture('legal_mget_with_indices.json')))
      request = described_class.new(env)
      expect(request.indices?).to be true
    end
  end

  context '#indices' do
    it 'reports the correct indices' do
      env = get_env('GET /_mget').merge('rack.input' => StringIO.new(get_fixture('legal_mget_with_indices.json')))
      request = described_class.new(env)
      expect(request.indices).to eq ['test-user-today', 'test-user-yesterday']
    end
  end
end

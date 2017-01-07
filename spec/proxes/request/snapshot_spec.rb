# frozen_string_literal: true
require 'spec_helper'
require 'proxes/request/snapshot'

describe ProxES::Request::Snapshot do
  def get_env(request)
    meth, path = request.split(' ')
    {
      'REQUEST_METHOD' => meth,
      'PATH_INFO' => path,
      'REQUEST_PATH' => path,
      'REQUEST_URI' => path
    }
  end

  context '.from_env' do
    it 'returns a Snapshot request' do
      expect(ProxES::Request.from_env(get_env('GET /_snapshot'))).to be_a(described_class)
      expect(ProxES::Request.from_env(get_env('GET /_snapshot/repository'))).to be_a(described_class)
    end

    it 'gives the endpoint as _snapshot' do
      expect(ProxES::Request.from_env(get_env('GET /_snapshot')).endpoint).to eq '_snapshot'
    end
  end

  context '#indices?' do
    it 'does not have indices' do
      request = described_class.new(get_env('GET /_search'))
      expect(request.indices?).to be false
    end
  end

  context '#repository' do
    it 'defaults to _all repositories if none specified' do
      request = described_class.new(get_env('GET /_snapshot'))
      expect(request.repository).to eq([])
    end

    it 'returns the specified repository' do
      request = described_class.new(get_env('GET /_snapshot/testrepo'))
      expect(request.repository).to eq(['testrepo'])
    end

    it 'returns an array of repositories if more than one is specified' do
      request = described_class.new(get_env('GET /_snapshot/one,two'))
      expect(request.repository).to eq(%w(one two))
    end
  end
end

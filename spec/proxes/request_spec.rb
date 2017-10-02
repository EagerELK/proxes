# frozen_string_literal: true

require 'spec_helper'
require 'proxes/request'

describe ProxES::Request do
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
    it 'returns a rack request' do
      expect(described_class.from_env(get_env('GET /_search'))).to be_a(Rack::Request)
      expect(described_class.from_env(get_env('GET /_search'))).to be_a(ProxES::Request)
    end
  end

  context '#endpoint' do
    it 'interprets no path as a root endpoint' do
      expect(described_class.path_endpoint('/')).to eq '_root'
      expect(described_class.path_endpoint('')).to eq '_root'
      expect(described_class.path_endpoint(nil)).to eq '_root'
    end

    it 'interprets /_search as a search endpoint' do
      expect(described_class.path_endpoint('/_search')).to eq '_search'
    end

    it 'interprets /indexname/_search as a search endpoint' do
      expect(described_class.path_endpoint('/indexname/_search')).to eq '_search'
    end

    it 'interprets /_search/scroll as a search endpoint' do
      expect(described_class.path_endpoint('/_search/scroll')).to eq '_search'
    end

    it 'interprets /_stats as a stats endpoint' do
      expect(described_class.path_endpoint('/_stats')).to eq '_stats'
    end

    it 'interprets /indexname/_stats as a stats endpoint' do
      expect(described_class.path_endpoint('/_stats')).to eq '_stats'
    end

    it 'interprets /_snapshot as a snapshot endpoint' do
      expect(described_class.path_endpoint('/_snapshot')).to eq '_snapshot'
    end

    it 'interprets /_snapshot/repository as a snapshot endpoint' do
      expect(described_class.path_endpoint('/_snapshot/repository')).to eq '_snapshot'
    end

    it 'interprets /_cat as a cat endpoint' do
      expect(described_class.path_endpoint('/_cat')).to eq '_cat'
    end

    it 'interprets /_cat/type as a cat endpoint' do
      expect(described_class.path_endpoint('/_cat/type')).to eq '_cat'
    end
  end
end

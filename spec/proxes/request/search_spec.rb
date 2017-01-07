# frozen_string_literal: true
require 'spec_helper'
require 'proxes/request/search'

describe ProxES::Request::Search do
  def get_env(request)
    meth, path = request.split(' ')
    {
      'REQUEST_METHOD' => meth,
      'PATH_INFO' => path,
      'REQUEST_PATH' => path,
      'REQUEST_URI' => path
    }
  end

  context '#indices?' do
    it 'does have indices' do
      request = described_class.new(get_env('GET /_search'))
      expect(request.indices?).to be true
    end
  end

  {
    '/_all' => {
      endpoint: nil,
      index: [],
      type: nil,
      id: nil
    },
    '/some-index/_all' => {
      endpoint: nil,
      index: ['some-index'],
      type: [],
      id: nil
    },
    '/some-index/some-type/some-id' => {
      endpoint: nil,
      index: ['some-index'],
      type: ['some-type'],
      id: ['some-id']
    },
    '/some-index/some-type/_search' => {
      endpoint: nil,
      index: ['some-index'],
      type: ['some-type'],
      id: nil
    }
  }.each do |path, values|
    context '.from_env' do
      it 'returns a Search request' do
        expect(ProxES::Request.from_env(get_env('GET /_search'))).to be_a(described_class)
      end

      it 'gives the endpoint as _search' do
        expect(ProxES::Request.from_env(get_env('GET /_search')).endpoint).to eq '_search'
      end
    end

    context 'accessors' do
      subject do
        ProxES::Request::Search.new('PATH_INFO' => path,
                                    'REQUEST_PATH' => path,
                                    'REQUEST_URI' => path)
      end

      it "provides the index for #{path} as #{values[:index]}" do
        expect(subject.index).to eq values[:index]
      end

      it "provides the type for #{path} as #{values[:type]}" do
        expect(subject.type).to eq values[:type]
      end

      it "provides the id for #{path} as #{values[:id]}" do
        expect(subject.id).to eq values[:id]
      end
    end
  end
end

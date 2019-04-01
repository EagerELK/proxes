# frozen_string_literal: true

require 'spec_helper'
require 'proxes/request/mapping'

describe ProxES::Request::Mapping do
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
    it 'returns a Mapping request' do
      expect(ProxES::Request.from_env(get_env('GET /_mapping'))).to be_a(described_class)
    end

    it 'gives the endpoint as _mapping' do
      expect(ProxES::Request.from_env(get_env('GET /_mapping')).endpoint).to eq '_mapping'
    end
  end

  context '#indices?' do
    it 'does have indices' do
      request = described_class.new(get_env('GET /_mapping'))
      expect(request.indices?).to be true
    end
  end

  context '#indices' do
    it 'reports the correct indices' do
      request = described_class.new(get_env('GET /index_one,index_two/_mapping'))
      expect(request.indices).to eq %w[index_one index_two]
    end
  end

  context '#type' do
    it 'reports the correct type' do
      request = described_class.new(get_env('GET /_mapping/type1'))
      expect(request.type).to eq %w[type1]
    end

    it 'reports the correct type with an index' do
      request = described_class.new(get_env('GET /_all/_mapping/type2'))
      expect(request.type).to eq %w[type2]
    end
  end

  {
    '/_all/_mapping' => {
      endpoint: nil,
      index: [],
      type: nil,
      id: nil
    },
    '/some-index/_mapping' => {
      endpoint: nil,
      index: ['some-index'],
      type: [],
      id: nil
    },
    '/some-index/_mapping/_doc' => {
      endpoint: nil,
      index: ['some-index'],
      type: ['some-type'],
      id: ['some-id']
    }
  }.each do |path, values|
    context 'accessors' do
      subject do
        described_class.new('PATH_INFO' => path,
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

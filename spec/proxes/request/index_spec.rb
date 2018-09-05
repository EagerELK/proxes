# frozen_string_literal: true

require 'spec_helper'
require 'proxes/request/index'

describe ProxES::Request::Index do
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

  context '#index=' do
    it 'sets the index correclty' do
      subject = ProxES::Request.from_env(get_env('GET /index/type/id'))
      subject.index = ['index']
      expect(subject.path_info).to eq '/index/type/id'
    end
  end

  {
    '/index/type/id' => {
      endpoint: nil,
      index: ['index'],
      type: ['type'],
      id: ['id']
    }
  }.each do |path, values|
    context '.from_env' do
      it 'returns an Index request' do
        expect(ProxES::Request.from_env(get_env("GET #{path}"))).to be_a(described_class)
      end

      it 'gives the endpoint as _search' do
        expect(ProxES::Request.from_env(get_env("GET #{path}")).endpoint).to eq nil
      end
    end

    context 'accessors' do
      subject do
        ProxES::Request::Search.new('PATH_INFO' => path,
                                    'REQUEST_PATH' => path,
                                    'REQUEST_URI' => path)
      end

      fit "provides the index for #{path} as #{values[:index]}" do
        expect(subject.index).to eq values[:index]
      end

      fit "provides the type for #{path} as #{values[:type]}" do
        expect(subject.type).to eq values[:type]
      end

      fit "provides the id for #{path} as #{values[:id]}" do
        expect(subject.id).to eq values[:id]
      end
    end
  end
end

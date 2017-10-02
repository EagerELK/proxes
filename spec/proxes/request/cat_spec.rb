# frozen_string_literal: true

require 'spec_helper'
require 'proxes/request/cat'

describe ProxES::Request::Cat do
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
      request = described_class.new(get_env('GET /_cat/indices'))
      expect(request.indices?).to be true
    end
  end

  context '.from_env' do
    it 'returns a Cat request' do
      expect(ProxES::Request.from_env(get_env('GET /_cat'))).to be_a(described_class)
    end

    it 'gives the endpoint as _cat' do
      expect(ProxES::Request.from_env(get_env('GET /_cat')).endpoint).to eq '_cat'
    end
  end

  context 'accessors' do
    let(:values) do
      {
        endpoint: nil,
        index: ['some-index'],
        type: nil,
        id: nil
      }
    end

    subject do
      ProxES::Request::Cat.new('PATH_INFO' => '_cat/indices',
                               'REQUEST_PATH' => '_cat/indices',
                               'REQUEST_URI' => '_cat/indices')
    end

    it "provides the index for '_cat/indices'" do
      expect(subject.index).to be_nil
    end

    it "provides the type for '_cat/indices'" do
      expect(subject.type).to eq ['indices']
    end
  end
end

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

  context '.from_env' do
    it 'returns a Cat request' do
      expect(ProxES::Request.from_env(get_env('GET /_cat'))).to be_a(described_class)
    end

    it 'gives the endpoint as _cat' do
      expect(ProxES::Request.from_env(get_env('GET /_cat')).endpoint).to eq '_cat'
    end
  end

  context '_cat/indices' do
    subject do
      described_class.new('PATH_INFO' => '_cat/indices',
                          'REQUEST_PATH' => '_cat/indices',
                          'REQUEST_URI' => '_cat/indices')
    end

    it "provides the index for '_cat/indices'" do
      expect(subject.index).to be_nil
    end

    it "provides the type for '_cat/indices'" do
      expect(subject.type).to eq ['indices']
    end

    it 'does have indices' do
      request = described_class.new(get_env('GET /_cat/indices'))
      expect(request.indices?).to be true
    end

    context '/some-index' do
      subject do
        described_class.new('PATH_INFO' => '_cat/indices/some-index',
                            'REQUEST_PATH' => '_cat/indices/some-index',
                            'REQUEST_URI' => '_cat/indices/some-index')
      end

      it "provides the index for '_cat/indices'" do
        expect(subject.index).to eq ['some-index']
      end

      it "provides the type for '_cat/indices'" do
        expect(subject.type).to eq ['indices']
      end
    end
  end

  context '_cat/nodes' do
    subject do
      described_class.new('PATH_INFO' => '_cat/nodes',
                          'REQUEST_PATH' => '_cat/nodes',
                          'REQUEST_URI' => '_cat/nodes')
    end

    it "provides the index for '_cat/nodes'" do
      expect(subject.index).to be_nil
    end

    it "provides the type for '_cat/nodes'" do
      expect(subject.type).to eq ['nodes']
    end

    it 'does not have indices' do
      request = described_class.new(get_env('GET /_cat/nodes'))
      expect(request.indices?).to be false
    end
  end

  context '_cat/shards' do
    it 'does have indices' do
      request = described_class.new(get_env('GET /_cat/shards'))
      expect(request.indices?).to be true
    end
  end

  context '_cat/segments' do
    it 'does have indices' do
      request = described_class.new(get_env('GET /_cat/segments'))
      expect(request.indices?).to be true
    end
  end

  context '_cat/count' do
    it 'does have indices' do
      request = described_class.new(get_env('GET /_cat/count'))
      expect(request.indices?).to be true
    end
  end

  context '_cat/recovery' do
    it 'does have indices' do
      request = described_class.new(get_env('GET /_cat/recovery'))
      expect(request.indices?).to be true
    end
  end

  context '_cat/' do
    it 'does not have indices' do
      request = described_class.new(get_env('GET /_cat/'))
      expect(request.indices?).to be false
    end
  end
end

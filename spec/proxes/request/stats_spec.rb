# frozen_string_literal: true

require 'spec_helper'
require 'proxes/request/stats'

describe ProxES::Request::Stats do
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
    it 'returns a Stats request' do
      expect(ProxES::Request.from_env(get_env('GET /index/_stats'))).to be_a(described_class)
    end

    it 'gives the endpoint as _stats' do
      expect(ProxES::Request.from_env(get_env('GET /index/_stats')).endpoint).to eq '_stats'
    end
  end

  context '/some-index/_stats' do
    subject do
      ProxES::Request::Stats.new('PATH_INFO' => '/some-index/_stats',
                                 'REQUEST_PATH' => '/some-index/_stats',
                                 'REQUEST_URI' => '/some-index/_stats')
    end

    it "provides the index for '/some-index/_stats'" do
      expect(subject.index).to include 'some-index'
    end

    it "provides the stats for '/some-index/_stats'" do
      expect(subject.stats).to be_nil
    end

    it 'does have indices' do
      request = described_class.new(get_env('GET /some-index/_stats'))
      expect(request.indices?).to be true
    end

    context '/docs,stats' do
      subject do
        ProxES::Request::Stats.new('PATH_INFO' => '/some-index/_stats/docs,stats',
                                   'REQUEST_PATH' => '/some-index/_stats/docs,stats',
                                   'REQUEST_URI' => '/some-index/_stats/docs,stats')
      end

      it "provides the index for 'docs,stats'" do
        expect(subject.index).to eq ['some-index']
      end

      it "provides the stats for 'docs,stats'" do
        expect(subject.stats).to eq %w[docs stats]
      end
    end
  end
end

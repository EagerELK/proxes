require 'spec_helper'
require 'proxes/es_request'

describe ProxES::ESRequest do
  {
    '/' => {
      endpoint: 'root',
      index: nil,
      type: nil,
      id: nil,
      action: nil,
    },
    '/_all' => {
      endpoint: nil,
      index: '_all',
      type: nil,
      id: nil,
      action: nil,
    },
    '/some-index/_all' => {
      endpoint: nil,
      index: 'some-index',
      type: '_all',
      id: nil,
      action: nil,
    },
    '/some-index/some-type/some-id' => {
      endpoint: nil,
      index: 'some-index',
      type: 'some-type',
      id: 'some-id',
      action: nil,
    },
    '/some-index/some-type/_search' => {
      endpoint: nil,
      index: 'some-index',
      type: 'some-type',
      id: nil,
      action: '_search',
    },
    '/_cluster/health' => {
      endpoint: '_cluster',
      index: nil,
      type: nil,
      id: nil,
      action: 'health',
    }
  }.each do |path, values|
    context 'accessors' do
      subject do
        ProxES::ESRequest.new({
          'PATH_INFO' => path,
          'REQUEST_PATH' => path,
          'REQUEST_URI' => path,
        })
      end

      it "provides the endpoint for #{path} as #{values[:endpoint]}" do
        expect(subject.endpoint).to eq values[:endpoint]
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

      it "provides the action for #{path} as #{values[:action]}" do
        expect(subject.action).to eq values[:action]
      end
    end
  end

  context '#index=' do
    it 'sets the index when none is give' do
      subject = ProxES::ESRequest.new({
        'PATH_INFO' => '/',
        'REQUEST_PATH' => '/',
        'REQUEST_URI' => '/',
      })

      subject.index= 'test'
      expect(subject.index).to eq 'test'
    end

    it 'does not affect the other attributes' do
      subject = ProxES::ESRequest.new({
        'PATH_INFO' => '/original',
        'REQUEST_PATH' => '/original',
        'REQUEST_URI' => '/original',
      })

      props = [subject.endpoint, 'new', subject.type, subject.id, subject.action]

      subject.index= 'new'
      expect([subject.endpoint, subject.index, subject.type, subject.id, subject.action]).to eq props
    end
  end
end

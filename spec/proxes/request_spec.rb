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
end

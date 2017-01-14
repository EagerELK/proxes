require 'spec_helper'
require 'proxes/services/usage'
require 'proxes/models/user'
require 'support/utilities'


describe ProxES::Services::Usage do
  context '.users' do
    it 'returns a Hash' do
      expect(described_class.users).to be_a Hash
    end

    it 'returns the user as the key' do
      expect(described_class.users.keys.first).to be_a ProxES::User
    end

    it 'returns the user\'s usage per cluster, node and index' do
      usage = described_class.users.values.first
      expect(usage).to be_a Hash
      expect(usage).to have_key(:clusters)
      expect(usage).to have_key(:nodes)
      expect(usage).to have_key(:indices)
    end

    fit 'returns the user\'s cluster usage as hashes, with the usage in bytes' do
      stub_es(:get, '/_nodes/stats/indices')

      usage = described_class.users.values.first
      expect(usage[:clusters]).to be_a Hash
      expect(usage[:clusters].keys.first).to be_a String
      expect(usage[:clusters].values.first).to be_a Fixnum
    end

    fit 'returns the user\'s nodes usage as hashes, with the usage in bytes' do
      stub_es(:get, '/_nodes/stats/indices')

      usage = described_class.users.values.first
      expect(usage[:nodes]).to be_a Hash
      expect(usage[:nodes].keys.first).to be_a String
      expect(usage[:nodes].values.first).to be_a Fixnum
    end

    fit 'returns the user\'s indices usage as hashes, with the usage in bytes' do
      stub_es(:get, '/_nodes/stats/indices')

      usage = described_class.users.values.first
      expect(usage[:indices]).to be_a Hash
      expect(usage[:indices].keys.first).to be_a String
      expect(usage[:indices].values.first).to be_a Fixnum
    end
  end
end

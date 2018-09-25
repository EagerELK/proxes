# frozen_string_literal: true

require 'spec_helper'
require 'proxes/models/permission'

RSpec.describe ProxES::Permission, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence :verb }
    it { is_expected.to validate_presence :pattern }
  end

  context '#pattern_regex' do
    it 'returns an empty regex if the pattern is nil' do
      subject = build(:permission, pattern: nil)
      expect(subject.pattern_regex).to eq Regexp.new('')
    end

    it 'returns a regex if the pattern is surrounded by pipes' do
      subject = create(:permission, pattern: '|.*|')
      expect(subject.pattern_regex).to be_a Regexp
    end

    it 'returns a regex if the pattern is not surrounded by pipes' do
      subject = create(:permission, pattern: '*')
      expect(subject.pattern_regex).to be_a Regexp
    end

    it 'anchors the pattern to the start of the regex' do
      subject = create(:permission, pattern: 'start')
      expect(subject.pattern_regex).to eq(Regexp.new('^start')).and match('start this')
    end

    it 'works with patterns that start with /' do
      subject = create(:permission, pattern: '/_bulk')
      expect(subject.pattern_regex).to eq(Regexp.new('^/_bulk')).and match('/_bulk/call')
    end

    it 'translates * to .*' do
      subject = create(:permission, pattern: '*')
      expect(subject.pattern_regex).to eq(Regexp.new('^.*')).and match('basically anything')
    end

    it 'translates * in a string to .*' do
      subject = create(:permission, pattern: 'something*')
      expect(subject.pattern_regex).to eq(Regexp.new('^something.*')).and match('something here')
    end

    it 'does not translate .*' do
      subject = create(:permission, pattern: 'check.*')
      expect(subject.pattern_regex).to eq Regexp.new '^check.*'
    end
  end

  context '#index_regex' do
    it 'returns an empty regex if the pattern is nil' do
      subject = build(:permission, index: nil)
      expect(subject.index_regex).to eq Regexp.new('')
    end

    it 'returns a regex if the pattern is surrounded by pipes' do
      subject = create(:permission, index: '|.*|')
      expect(subject.index_regex).to be_a Regexp
    end

    it 'returns a regex if the pattern is not surrounded by pipes' do
      subject = create(:permission, index: '*')
      expect(subject.index_regex).to be_a Regexp
    end

    it 'anchors the pattern to the start of the regex' do
      subject = create(:permission, index: 'start')
      expect(subject.index_regex).to eq(Regexp.new('^start')).and match('start this')
    end

    it 'works with patterns that start with /' do
      subject = create(:permission, index: '/_bulk')
      expect(subject.index_regex).to eq(Regexp.new('^/_bulk')).and match('/_bulk/call')
    end

    it 'translates * to .*' do
      subject = create(:permission, index: '*')
      expect(subject.index_regex).to eq(Regexp.new('^.*')).and match('basically anything')
    end

    it 'translates * in a string to .*' do
      subject = create(:permission, index: 'something*')
      expect(subject.index_regex).to eq(Regexp.new('^something.*')).and match('something here')
    end

    it 'does not translate .*' do
      subject = create(:permission, index: 'check.*')
      expect(subject.index_regex).to eq Regexp.new '^check.*'
    end
  end
end

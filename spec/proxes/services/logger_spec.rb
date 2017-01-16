# frozen_string_literal: true
require 'spec_helper'
require 'proxes/services/logger'

class TestLogger
  WARN = 2
  attr_accessor :level
  def initialize(options = {})
    @options = options
  end
end

RSpec.describe ProxES::Services::Logger, type: :service do
  let(:subject) { described_class.clone }
  config_file = [
    { 'name' => 'file', 'class' => 'Logger' },
    { 'name' => 'ES', 'class' => 'TestLogger', 'level' => 'WARN', options: {
      'url' => 'http://logging.proxes.io:9200', 'log' => false}
    }
  ]

  context 'initialize' do
    it '.instance always refers to the same instance' do
      expect(subject.instance).to eq subject.instance
    end

    it "creates default logger if config file does't exist" do
      expect(subject.instance.loggers[0]).to be_instance_of Logger
    end

    it 'reads config from file and creates an array of loggers' do
      allow(YAML).to receive(:load_file).and_return(config_file)

      expect(subject.instance.loggers.size).to eq 2
      expect(subject.instance.loggers[0]).to be_instance_of Logger
      expect(subject.instance.loggers[1]).to be_instance_of TestLogger
    end
  end

  context 'send messages' do
    it 'receives message and passes it to the loggers' do
      allow(YAML).to receive(:load_file).and_return(config_file)
      allow(Logger).to receive(:warn).with('Some message')
      allow(TestLogger).to receive(:warn).with('Some message')

      expect(subject.instance.loggers[0]).to receive(:warn).with('Some message')
      expect(subject.instance.loggers[1]).to receive(:warn).with('Some message')

      subject.instance.warn 'Some message'
    end
  end
end

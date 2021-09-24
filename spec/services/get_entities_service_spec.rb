# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GetEntitiesService, type: :model do
  mocked_model = Object.new
  def mocked_model.create_from; end

  def mocked_model.name
    ''
  end

  before do
    described_class.class_variable_set :@@model, mocked_model
  end

  describe 'GetEntitiesService::request' do
    successful_response = {
      'isAvailable' => true,
      'imageAvailable' => false,
      'values' => {}
    }.to_json

    it 'handle response successfully' do
      mock_response = instance_double(RestClient::Response, body: successful_response)
      allow(RestClient::Request).to receive(:execute).and_return(mock_response)
      expect(described_class.request).to be_truthy
    end

    it 'return nil when response fails' do
      allow(RestClient::Request).to receive(:execute)
        .and_raise(RestClient::ExceptionWithResponse)
      expect(described_class.request).to be_nil
    end
  end

  describe 'GetEntitiesService::parse' do
    before do
      described_class.class_variable_set :@@data, [[], []]
    end

    it 'return the record when it is successfully created' do
      allow(mocked_model).to receive(:create_from).and_return(true)
      expect(described_class.parse).to be_truthy
    end

    it 'does not raise errors when record creation fails' do
      allow(mocked_model).to receive(:create_from)
        .and_raise(Mongoid::Errors::Validations, Company.new)
      expect { described_class.parse }.not_to raise_error
    end
  end

  describe 'GetEntitiesService::run' do
    it 'calls request, cleanup, parse and report methods if used correct args' do
      symbols = %i[request cleanup parse report]
      symbols.each do |symbol|
        allow(described_class).to receive(symbol).and_return(true)
      end

      described_class.run mocked_model
      symbols.each do |symbol|
        expect(described_class).to have_received(symbol)
      end
    end

    it 'does not cleanup if request failed' do
      allow(described_class).to receive(:request).and_return(nil)
      allow(described_class).to receive(:cleanup)
      described_class.run mocked_model

      expect(described_class).not_to have_received(:cleanup)
    end

    it 'does not parse if cleanup failed' do
      allow(described_class).to receive(:request).and_return(true)
      allow(described_class).to receive(:cleanup).and_return(nil)
      allow(described_class).to receive(:parse)
      described_class.run mocked_model

      expect(described_class).not_to have_received(:parse)
    end

    it 'parses even if cleanup returns 0' do
      allow(described_class).to receive(:request).and_return(true)
      allow(described_class).to receive(:cleanup).and_return(0)
      allow(described_class).to receive(:parse)
      described_class.run mocked_model

      expect(described_class).to have_received(:parse)
    end

    it 'does not report if with_report argument is false' do
      allow(described_class).to receive(:report)
      described_class.run(mocked_model, with_report: false)

      expect(described_class).not_to have_received(:report)
    end
  end
end

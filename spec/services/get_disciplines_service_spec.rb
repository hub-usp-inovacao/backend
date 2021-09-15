# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GetDisciplinesService, type: :model do
  describe 'GetDisciplinesService::request' do
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

  describe 'GetDisciplinesService::parse' do
    before do
      described_class.class_variable_set :@@data, [[], []]
    end

    it 'return the record when it is successfully created' do
      allow(Discipline).to receive(:create_from).and_return(true)
      expect(described_class.parse).to be_truthy
    end

    it 'does not raise errors when record creation fails' do
      allow(Discipline).to receive(:create_from)
        .and_raise(Mongoid::Errors::Validations, Discipline.new)
      expect { described_class.parse }.not_to raise_error
    end
  end

  describe 'GetDisciplinesService::run' do
    it 'does not cleanup if request failed' do
      allow(described_class).to receive(:request).and_return(nil)
      allow(described_class).to receive(:cleanup)
      described_class.run

      expect(described_class).not_to have_received(:cleanup)
    end

    it 'does not parse if cleanup failed' do
      allow(described_class).to receive(:request).and_return(true)
      allow(described_class).to receive(:cleanup).and_return(nil)
      allow(described_class).to receive(:parse)
      described_class.run

      expect(described_class).not_to have_received(:parse)
    end
  end
end

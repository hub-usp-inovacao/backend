# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GetDisciplinesService, type: :model do
  describe 'GetDisciplinesService::request' do
    before do
      mock_response = instance_double(RestClient::Response,
                                      body: {
                                        'isAvailable' => true,
                                        'imageAvailable' => false
                                      }.to_json)

      allow(RestClient::Request).to receive(:execute).and_return(mock_response)

      @response = described_class.request
    end

    it 'handle response successfully' do
      expect(@response).to be_truthy
    end
  end

  describe 'GetDisciplinesService::parse' do
    before do
      described_class.class_variable_set :@@data, [[], []]
    end

    it 'does not raise errors' do
      allow(Discipline).to receive(:create_from).and_return(true)
      expect { described_class.parse }.not_to raise_error
    end

    it 'does raise errors' do
      allow(Discipline).to receive(:create_from)
        .and_raise(Mongoid::Errors::Validations, Discipline.new)
      expect(described_class.parse).to be_nil
    end
  end
end

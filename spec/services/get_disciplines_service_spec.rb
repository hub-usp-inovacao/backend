# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GetDisciplinesService, type: :model do
  context 'GetDisciplinesService::request' do
    before do
      mock_response = instance_double(RestClient::Response,
                                      body: {
                                        'isAvailable' => true,
                                        'imageAvailable' => false
                                      }.to_json)

      allow(RestClient::Request).to receive(:execute).and_return(mock_response)

      @response = GetDisciplinesService.request
    end

    it 'get status 200' do
      expect(@response).to be_truthy
    end
  end

  context 'GetDisciplinesService::parse' do
    it 'does not raise errors' do
      # Mocar o comportamento do create e checar se levanta exceções
      allow(Discipline).to receive(:create!).and_return(true)
      expect { GetDisciplinesService.parse }.not_to raise_error
    end

    it 'does raise errors' do
      # Erro no mock
      GetDisciplinesService.class_variable_set :@@data, [[], []]
      allow(Discipline).to receive(:create_from).with([]).and_raise(Mongoid::Errors::Validations)
      expect(GetDisciplinesService.parse).to be_nil
    end
  end
end

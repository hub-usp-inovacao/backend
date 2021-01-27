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
    before do
      mocked_data = [
        [],
        [
          'Graduação',
          'ACH1575 - Inovação em Serviços de Lazer e Turismo',
          'USP Leste',
          'Escola de Artes, Ciências e Humanidades - EACH',
          'https://uspdigital.usp.br/jupiterweb/obterDisciplina?sgldis=ACH1575',
          'Preciso testar minha ideia!',
          'Foo',
          'Bar',
          '2020',
          '',
          'X',
          '',
          '',
          'X'
        ]
      ]
      GetDisciplinesService.class_variable_set :@@data, mocked_data
    end

    it 'does not raise errors' do
      # Mocar o comportamento do create e checar se levanta exceções
      expect { GetDisciplinesService.parse }.not_to raise_error
      expect (Discipline).to receive(:create!)
    end
  end
end

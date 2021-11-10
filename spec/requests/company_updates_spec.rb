# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CompanyUpdates', type: :request do
  let(:valid_data) do
    {
      name: 'fulano',
      cnpj: '12.123.123/0001-21',
      partners_values: [
        {
          name: 'Paulo',
          phone: '11 999999999',
          email: 'Foo@bar.com',
          bond: 'Aluno ou ex-aluno (graduação)',
          nusp: '11111111',
          unity: 'Escola de Artes, Ciências e Humanidades - EACH'
        },
        {
          name: 'Paulo Outro',
          phone: '11 999999999',
          email: 'Foo@bar.com',
          bond: '',
          nusp: '',
          unity: ''
        }
      ],
      company_values: {
        CEP: '05331-020'
      },
      dna_values: {
        wants_dna: true,
        name: 'Paulo',
        email: 'paulo@example.com'
      }
    }
  end

  describe 'PATCH /companies' do
    before do
      CompanyUpdate.delete_all
    end

    it 'blocks requests that fails validation' do
      params = valid_data.clone
      %i[partners_values company_values dna_values].each { |k| params.delete k }
      patch '/companies', params: { company: params }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns the just-created object' do
      patch '/companies', params: { company: valid_data }
      body = JSON.parse response.body
      expect(body['company_update']['_id']).not_to be_nil
    end
  end
end

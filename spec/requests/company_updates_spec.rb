# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CompanyUpdates', type: :request do
  let(:valid_data) do
    {
      cnpj: '1234.4321.4232/0001.21',
      name: 'fulano',
      partners_values: [
        {
          name: 'Paulo',
          phone: '11 999999999',
          email: 'Foo@bar.com',
          bond: 'Aluno ou ex-aluno de graduação',
          nusp: '11111111',
          unity: 'Escola de Comunicação e Artes - ECA'
        }
      ],
      company_values: [
        { Foo: 'Bar' }
      ]
    }
  end

  describe 'PATCH /companies' do
    it 'blocks requests that fails validation' do
      allow(CompanyUpdate).to receive(:create!) { raise ActiveRecord::RecordInvalid }
      patch '/companies'
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns the just-created object' do
      comp_update = valid_data.merge({ id: 'hand-made-id' })

      allow(CompanyUpdate).to receive(:create!).and_return(comp_update)
      patch '/companies', params: { company: valid_data }
      expect(response.body).to eql({ company_update: comp_update }.to_json)
    end
  end
end

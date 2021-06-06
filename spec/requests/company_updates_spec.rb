# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CompanyUpdates', type: :request do
  describe 'PATCH /companies' do
    it 'blocks requests that fails validation' do
      allow(CompanyUpdate).to receive(:create!) { raise ActiveRecord::RecordInvalid }
      patch '/companies'
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns the just-created object' do
      data = { cnpj: '1234.4321.4232/0001.21', new_values: [{ email: 'foo@example.com' }] }
      comp_update = data.merge({ id: '1097bd190328aaf98' })

      allow(CompanyUpdate).to receive(:create!).and_return(comp_update)
      patch '/companies', params: { company: data }
      expect(response.body).to eql({ company_update: comp_update }.to_json)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Companies', type: :request do
  let(:companies) do
    [
      {
        name: 'Uber 99',
        year: '2019',
        services: 'foo bar baz',
        incubated: false,
        emails: [
          'foo@exmaple.com',
          'bar@exmaple.com'
        ],
        ecosystems: [
          'ESALQTec'
        ],
        description: {
          long: 'foo bar baz'
        },
        allowed: true,
        address: {
          cep: '13414-157',
          city: ['Piracicaba'],
          neightborhood: 'Loteamento Santa Rosa',
          state: 'São Paulo',
          venue: 'Rua Cezira Giovanni'
        },
        active: true,
        url: 'https://techagr.com',
        technologies: ['foo bar baz'],
        phones: ['(11) 987288877'],
        logo: 'https://drive.google.com/...',
        companySize: ['Média Empresa'],
        classification: {
          major: 'Comércio e Serviços',
          minor: 'Informação e Comunicação'
        }
      }
    ]
  end

  def company_keys
    %w[_id name year services incubated emails ecosystems
       description allowed address active url technologies
       phones logo companySize classification created_at]
  end

  describe 'GET /companies' do
    before do
      allow(Company).to receive(:all).and_return(companies)
      get '/companies'
    end

    it 'returns a response with success http status' do
      expect(response).to have_http_status(:success)
    end

    it 'returns a list of all companies with expected format' do
      resp = JSON.parse(response.body)
      resp.each do |discipline|
        expect(discipline.keys.difference(company_keys)).to eq([])
      end
    end
  end
end

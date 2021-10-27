# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Companies', type: :request do
  cnpj = '12.123.123/0001-21'

  let(:companies) do
    [
      {
        cnpj: cnpj,
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
          neighborhood: 'Loteamento Santa Rosa',
          state: 'São Paulo',
          venue: 'Rua Cezira Giovanni'
        },
        active: true,
        url: 'https://techagr.com',
        technologies: ['foo bar baz'],
        phones: ['(11) 987288877'],
        logo: 'https://drive.google.com/...',
        companySize: ['Média Empresa'],
        cnae: '66.13-4-00',
        classification: {
          major: 'Comércio e Serviços',
          minor: 'Informação e Comunicação'
        },
        partners: [
          {
            name: 'Fulano de Tal',
            nusp: '1234567',
            bond: 'Pesquisador',
            unity: 'Faculdade de Odontologia de Bauru - FOB',
            email: 'fulano@detal.com',
            phone: '(11) 99999-9999'
          },
          {
            name: '',
            nusp: '',
            bond: '',
            unity: '',
            email: '',
            phone: ''
          },
          {
            name: '',
            nusp: '',
            bond: '',
            unity: '',
            email: '',
            phone: ''
          },
          {
            name: '',
            nusp: '',
            bond: '',
            unity: '',
            email: '',
            phone: ''
          },
          {
            name: '',
            nusp: '',
            bond: '',
            unity: '',
            email: '',
            phone: ''
          }
        ],
        corporate_name: 'razão social',
        number_of_clt_employees: 1,
        number_of_pj_colaborators: 1,
        number_of_interns: 1,
        received_investments: false,
        investments: [],
        investments_values: {
          own: '',
          angel: '',
          venture_capital: '',
          private_equity: '',
          pipe_fapesp: '',
          other: ''
        }
      }
    ]
  end

  def company_keys
    %w[_id name year services incubated emails ecosystems
       description allowed address active url technologies
       phones logo companySize classification created_at
       partners corporate_name number_of_interns investments
       received_investments investments_values cnae cnpj
       number_of_clt_employees number_of_pj_colaborators]
  end

  before do
    Company.create!(companies)
    get '/companies'
  end

  after do
    Company.delete_all
  end

  describe 'GET /companies' do
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

  describe 'GET /companies?cnpj=' do
    describe 'when a company is found' do
      before do
        get '/companies', params: { cnpj: cnpj }
      end

      it 'returns :ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the company' do
        body = JSON.parse(response.body)
        expect(body['cnpj']).to eql(cnpj)
      end
    end

    describe 'when a company is not found' do
      before do
        get '/companies', params: { cnpj: '12.123.000/0001-21' }
      end

      it 'returns :not_found' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error' do
        body = JSON.parse(response.body)
        expect(body).to eql({ 'error' => 'not_found' })
      end
    end
  end
end

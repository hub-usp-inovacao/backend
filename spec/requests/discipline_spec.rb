# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Disciplines', type: :request do
  let(:disciplines) do
    [
      {
        name: 'ACH1575 - Inovação em Serviços de Lazer e Turismo',
        campus: 'USP Leste',
        unity: 'Escola de Artes, Ciências e Humanidades - EACH',
        start_date: '2020',
        nature: 'Graduação',
        level: 'Preciso testar minha ideia!',
        url: 'https://uspdigital.usp.br/jupiterweb/obterDisciplina?sgldis=ACH1575',
        description: {
          short: 'Foo',
          long: 'Bar'
        },
        category: {
          business: false,
          entrepreneurship: false,
          innovation: true,
          intellectualProperty: false
        },
        keywords: ['Inovação']
      }
    ]
  end

  def discipline_keys
    %w[_id name campus unity start_date
       nature level url description
       category keywords created_at]
  end

  describe 'GET /index' do
    before do
      allow(Discipline).to receive(:all).and_return(disciplines)
      get '/disciplines'
    end

    it 'returns a response with success http status' do
      expect(response).to have_http_status(:success)
    end

    it 'returns a list of all disciplines with expected format' do
      resp = JSON.parse(response.body)
      resp.each do |discipline|
        expect(discipline.keys.difference(discipline_keys)).to eq([])
      end
    end
  end
end

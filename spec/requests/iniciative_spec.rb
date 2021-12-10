# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Iniciatives', type: :request do
  describe 'GET /iniciatives' do
    let :seeds do
      [
        {
          name: 'AUSPIN',
          classification: 'Agente Institucional',
          localization: 'Toda a USP',
          unity: nil,
          tags: %w[foo bar baz],
          url: 'http://google.com',
          description: {
            long: 'foo bar baz bar baz long text whatever'
          },
          email: 'auspin@usp.br',
          contact: '(11) 3091-4165'
        }
      ]
    end

    def iniciative_keys
      %w[_id name classification localization unity tags url description email contact]
    end

    before do
      Iniciative.create!(seeds)
      get '/iniciatives'
    end

    after do
      Iniciative.delete_all
    end

    it 'returns a response with success http status' do
      expect(response).to have_http_status(:success)
    end

    it 'returns a list of all iniciatives with expected format' do
      resp = JSON.parse(response.body)
      resp.each do |iniciative|
        expect(iniciative.keys.difference(iniciative_keys)).to eq([])
      end
    end
  end
end

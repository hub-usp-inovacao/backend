# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Skills', type: :request do
  let(:skill) do
    [
      '',
      'Docente',
      'Fulano Professor',
      'fulano@mail.com',
      '',
      'Faculdade de Filosofia, Letras e Ciências Humanas - FFLCH',
      'Butantã',
      '',
      'N/D',
      'N/D',
      'N/D',
      'N/D',
      'N/D',
      'N/D',
      'N/D',
      'N/D',
      'N/D',
      'N/D',
      'N/D',
      'N/D',
      'N/D',
      'N/D',
      'N/D',
      'foo;bar',
      'foo;bar',
      'foo;bar',
      'Ciências Humanas',
      'Sociologia',
      'foo;bar',
      'http://lattes.cnpq.br/7042243902784462',
      'N/D',
      '(11) 5555-8888',
      '',
      '',
      '',
      '',
      'N/D',
      ''
    ]
  end

  def skill_keys
    %w[_id name email unities keywords lattes photo skills services equipments research_groups
       phones limit_date bond campus area]
  end

  before do
    Skill.create_from skill
    get '/skills'
  end

  after do
    Skill.delete_all
  end

  describe 'GET /skill' do
    it 'responds with success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns a list correctly structured' do
      resp = JSON.parse(response.body)
      resp.each do |skill|
        expect(skill.keys.difference(skill_keys)).to eq([])
      end
    end
  end
end

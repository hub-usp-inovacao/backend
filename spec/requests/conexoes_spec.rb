# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Conexoes', type: :request do
  let(:valid_attr) do
    {
      requestId: 'request-id',
      personal: {
        name: 'Neymar',
        email: 'ney10@hotmail.com',
        represent: 'Empresa'
      },
      org: {
        name: 'Desempedidos',
        email: 'dsp@gmail.com',
        cnpj: '14.952.400/0002-31',
        sensitiveData: 'Não',
        size: 'Média',
        phone: '11 961442245',
        address: 'rua do Matão, 1010',
        city: 'São Paulo'
      },
      demand: {
        cnae: {
          major: 'Indústria de Transformação',
          minor: 'Bebidas'
        },
        description: 'Quero elaborar um novo produto para jogadores de futebol',
        expectation: 'Novo produto',
        wantedProfile: 'Saúde',
        necessity: 'Desenvolvimento de P&D em parceria'
      }
    }
  end

  let(:valid_img) do
    fixture_file_upload('spec/requests/test_images/test.png', 'image/png')
  end

  describe 'POST /conexao' do
    before do
      post '/conexao', params: { conexao: valid_attr }
    end

    after do
      Conexao.delete_all
    end

    it 'returns the just-created object' do
      body = JSON.parse(response.body)
      expect(body['conexao']['_id']).not_to be_nil
    end

    it 'blocks requests that fail validation' do
      attr = valid_attr.clone
      attr.delete(:demand)
      post '/conexao', params: { conexao: attr }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST /conexao/image' do
    after do
      Conexao.delete_all
      Image.delete_all
    end

    it 'returns status success when conexao instance already exists' do
      Conexao.create!(valid_attr)
      post '/conexao/image', params: { requestId: 'request-id', image: valid_img, multipart: true }
      expect(response).to have_http_status(:success)
    end

    it 'blocks the request when conexao instance does not exist' do
      post '/conexao/image', params: { requestId: 'request-id', image: '', multipart: true }
      expect(response).to have_http_status(:bad_request)
    end
  end
end

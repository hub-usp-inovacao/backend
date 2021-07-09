# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conexao, type: :model do
  let(:valid_attr) do
    {
      personal: {
        name: 'Neymar',
        email: 'ney10@hotmail.com',
        represent: 'Empresa'
      },
      org: {
        name: 'Desempedidos',
        email: 'dsp@gmail.com',
        cnpj: '14.952.400/0002-31',
        sensitiveData: false,
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

  it 'is valid with valid attributes' do
    conexao = described_class.new(valid_attr)
    expect(conexao).to be_valid
  end

  describe 'Org Hash' do
    %i[cnpj sensitiveData size].each do |attr_name|
      it "is invalid with invalid #{attr_name}" do
        attr = valid_attr
        attr[:org][attr_name] = '1127829784'
        conexao = described_class.new(attr)
        expect(conexao).to be_invalid
      end
    end
  end

  describe 'Demand Hash' do
    %i[major minor].each do |attr_name|
      it "is invalid with invalid cnae #{attr_name} area" do
        attr = valid_attr
        attr[:demand][:cnae][attr_name] = '1127829784'
        conexao = described_class.new(attr)
        expect(conexao).to be_invalid
      end
    end

    it 'is invalid with invalid wantedProfile' do
      attr = valid_attr
      attr[:demand][:wantedProfile] = '1127829784'
      conexao = described_class.new(attr)
      expect(conexao).to be_invalid
    end
  end
end

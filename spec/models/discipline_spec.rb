# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Discipline, type: :model do
  let(:valid_att) do
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
  end

  it 'is valid with valid attributes' do
    discipline = described_class.new(valid_att)
    expect(discipline).to be_valid
  end

  it 'is invalid with an invalid name' do
    attr = valid_att
    attr[:name] = 'Foo'
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid
  end

  it 'is invalid with an invalid URL' do
    attr = valid_att
    attr[:url] = 'Foo'
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid
  end

  it 'is invalid with an invalid level' do
    attr = valid_att
    attr[:level] = 'Foo'
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid
  end

  it 'is invalid with an invalid nature' do
    attr = valid_att
    attr[:nature] = 'Foo'
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid
  end

  it 'is invalid with an invalid campus' do
    attr = valid_att
    attr[:campus] = 'Foo'
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid
  end

  it 'is invalid with an invalid unity' do
    attr = valid_att
    attr[:unity] = 'Foo'
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid
  end

  it 'is invalid without category' do
    attr = valid_att
    attr[:category][:innovation] = false
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid
  end
end

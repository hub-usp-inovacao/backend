# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Discipline, type: :model do
  before do
    @att = {
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
    discipline = described_class.new(@att)
    expect(discipline).to be_valid  
  end

  it "is invalid with a invalid name" do
    attr = @att
    attr['name'] = "Foo"
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid 
  end

  it 'is invalid with a invalid URL' do
    attr = @att
    attr['url'] = "Foo"
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid 
  end

  it 'is invalid with a invalid URL' do
    attr = @att
    attr['url'] = "Foo"
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid 
  end

  it 'is invalid with a invalid nature' do
    attr = @att
    attr['nature'] = "Foo"
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid 
  end

  it 'is invalid with a invalid campus' do
    attr = @att
    attr['campus'] = "Foo"
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid 
  end

  it 'is invalid with a invalid unity' do
    attr = @att
    attr['unity'] = "Foo"
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid 
  end

  it 'is invalid with a invalid category' do
    attr = @att
    attr['category'] = {
      business: false,
      entrepreneurship: false,
      innovation: false,
      intellectualProperty: false
    }
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid 
  end
end

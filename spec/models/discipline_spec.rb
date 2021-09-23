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
      offeringPeriod: 'N/D',
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

  %i[name url level nature campus unity].each do |att_name|
    it "is invalid with an invalid #{att_name}" do
      attr = valid_att
      attr[att_name] = 'Foo'
      discipline = described_class.new(attr)
      expect(discipline).to be_invalid
    end
  end

  %i[name campus unity description category nature level].each do |field|
    it "is invalid without #{field}" do
      attrs = valid_att.clone
      attrs.delete(field)

      patent = described_class.new attrs
      expect(patent).to be_invalid
    end
  end

  it 'is invalid without category' do
    attr = valid_att
    attr[:category][:innovation] = false
    discipline = described_class.new(attr)
    expect(discipline).to be_invalid
  end
end

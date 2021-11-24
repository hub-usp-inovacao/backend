# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Skill, type: :model do
  let(:valid_attr) do
    {
      name: 'Alfie',
      email: 'alfie@usp.br',
      unities: ['Faculdade de Saúde Pública - FSP'],
      keywords: %w[foo bar baz],
      lattes: 'http://lattes.cnpq.br/3689433102442300',
      photo: 'https://drive.google.com/uc?export=view&id=1cmsUahKZ6fMsat4P9QFWyOM9T9CWA-cw',
      skills: ['matlab'],
      services: ['programação linear'],
      equipments: ['computador'],
      phones: ['(11) 3167-8977'],
      limit_date: Date.tomorrow,
      bond: 'Docente'
    }
  end

  it 'is valid with valid attributes' do
    skill = described_class.new valid_attr
    expect(skill).to be_valid
  end

  it 'is invalid with invalid unity' do
    attr = valid_attr
    attr[:unities] = ['foo']
    skill = described_class.new attr
    expect(skill).to be_invalid
  end

  it 'is invalid with empty keyword' do
    attr = valid_attr
    attr[:keywords] = ['foo', '']
    skill = described_class.new attr
    expect(skill).to be_invalid
  end

  it 'is invalid with numeric keyword' do
    attr = valid_attr
    attr[:keywords] = ['foo', 123]
    skill = described_class.new attr
    expect(skill).to be_invalid
  end

  it 'is valid with nil photo' do
    attr = valid_attr
    attr[:photo] = nil
    skill = described_class.new attr
    expect(skill).to be_valid
  end

  it 'is valid with empty array' do
    valid_attr[:phones] = []
    skill = described_class.new valid_attr
    expect(skill).to be_valid
  end

  it 'is invalid with unknown bond' do
    valid_attr[:bond] = 'whatever'
    skill = described_class.new valid_attr
    expect(skill).to be_invalid
  end

  it 'blocks duplicated names' do
    described_class.create valid_attr
    skill = described_class.new valid_attr
    expect(skill).to be_invalid
    described_class.delete_all
  end
end

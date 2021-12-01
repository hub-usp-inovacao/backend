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
      bond: 'Docente',
      campus: 'São Carlos',
      area: {
        major: 'Ciências Biológicas',
        minor: 'Bioquímica'
      }
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

  it 'is valid with empty array of phones' do
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

  context 'with date parsing' do
    ['Março de 2023', 'Não', 'Sim'].each do |arg|
      it "is valid with limit date '#{arg}' due to mongoid" do
        valid_attr[:limit_date] = arg
        expect(described_class.new(valid_attr)).to be_valid
      end
    end
  end

  context 'with campus infering' do
    it 'infers campus from unity' do
      unity = 'Instituto de Química de São Carlos - IQSC'
      campus = 'São Carlos'
      expect(described_class.infer_campus(unity)).to eql(campus)
    end

    it 'returns nil if no campus is found' do
      unity = 'foo'
      expect(described_class.infer_campus(unity)).to be_nil
    end
  end

  context 'with area infering' do
    it 'infers major from minor' do
      minor = 'Parasitologia'
      major = 'Ciências Biológicas'
      expect(described_class.infer_major(minor)).to eql(major)
    end

    it 'returns nil if no major is found' do
      minor = 'foo'
      expect(described_class.infer_major(minor)).to be_nil
    end
  end
end

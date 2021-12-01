# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResearchGroup, type: :model do
  let(:valid_attr) do
    {
      bond: 'Coordenador',
      categories: ['NAP'],
      name: 'Núcleo de Pesquisa em Avaliação de Riscos ambientais',
      initials: 'NPARA',
      site: 'http://foundationgolden.org/'
    }
  end

  it 'is valid with valid attributes' do
    group = described_class.new valid_attr
    expect(group).to be_valid
  end

  %i[bond name categories].each do |attr|
    it "is invalid without #{attr} - required attributes" do
      attrs = valid_attr.clone
      attrs.delete attr
      group = described_class.new attrs
      expect(group).to be_invalid
    end
  end

  it 'is invalid with malformed site' do
    valid_attr[:site] = 'foo bar baz'
    group = described_class.new valid_attr
    expect(group).to be_invalid
  end

  it 'is valid without site' do
    valid_attr.delete :site
    group = described_class.new valid_attr
    expect(group).to be_valid
  end

  it 'is valid with nil site' do
    valid_attr[:site] = nil
    expect(described_class.new(valid_attr)).to be_valid
  end

  describe 'new_from' do
    it 'throws when arguments are invalid' do
      args = [nil, nil, nil, nil, nil]
      expect { described_class.new_from args }.to raise_error(StandardError)
    end

    it 'does not throw when arguments are N/D' do
      args = ['N/D'] * 5
      expect { described_class.new_from args }.not_to raise_error
    end
  end
end

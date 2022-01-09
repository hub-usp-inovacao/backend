# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Iniciative, type: :model do
  context 'with validations' do
    let :valid_attr do
      {
        name: 'AUSPIN',
        classification: 'Agente Institucional',
        localization: 'Toda a USP',
        unity: 'N/D',
        tags: %w[foo bar baz],
        url: 'http://google.com',
        description: {
          long: 'foo bar baz bar baz long text whatever'
        },
        email: 'auspin@usp.br',
        contact: '(11) 3091-4165'
      }
    end

    it 'is valid with valid attributes' do
      expect(described_class.new(valid_attr)).to be_valid
    end

    %i[name classification localization].each do |attr|
      it "is invalid without #{attr}" do
        valid_attr.delete attr
        expect(described_class.new(valid_attr)).to be_invalid
      end
    end

    it 'is valid with name too short' do
      valid_attr[:name] = 'a'
      expect(described_class.new(valid_attr)).to be_valid
    end

    it 'is valid with name too long' do
      valid_attr[:name] = 'a' * 101
      expect(described_class.new(valid_attr)).to be_valid
    end

    it 'is invalid with wrong classification' do
      valid_attr[:classification] = 'foo'
      expect(described_class.new(valid_attr)).to be_invalid
    end

    it 'is invalid with wrong localization' do
      valid_attr[:localization] = 'foo'
      expect(described_class.new(valid_attr)).to be_invalid
    end

    it 'is invalid with wrong unity' do
      valid_attr[:unity] = 'foo'
      expect(described_class.new(valid_attr)).to be_invalid
    end

    it 'is invalid with malformed url' do
      valid_attr[:url] = 'foo'
      expect(described_class.new(valid_attr)).to be_invalid
    end

    [{}, { foo: 'ahsdu asdb' }].each do |value|
      it 'is invalid with malformed description hash' do
        valid_attr[:description] = value
        expect(described_class.new(valid_attr)).to be_invalid
      end
    end

    %i[email contact].each do |attr|
      it "is is valid with #{attr} nil" do
        valid_attr[attr] = nil
        expect(described_class.new(valid_attr)).to be_valid
      end
    end
  end

  context 'with parsing' do
    let :valid_sheets do
      [
        'Agente Institucional',
        'AUSPIN',
        'N/D',
        'Toda a USP',
        'N/D',
        'Patentes;Marcas;Software;Empreendedorismo;Licenciamento',
        'https://google.com',
        'foo bar baz',
        nil,
        '',
        '',
        '',
        'N/D'
      ]
    end

    it 'parses correctly' do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(described_class).to receive(:save).and_call_original
      # rubocop:enable RSpec/AnyInstance
      expect { described_class.create_from(valid_sheets) }.not_to raise_error
    end
  end
end

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
        description: 'foo bar baz bar baz long text whatever',
        email: 'auspin@usp.br',
        contact: {
          person: 'fulano',
          info: '99999-9999'
        }
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

    it 'is valid with string description' do
      valid_attr[:description] = 'description'
      expect(described_class.new(valid_attr)).to be_valid
    end

    it 'is valid with empty array' do
      valid_attr[:tags] = []
      expect(described_class.new(valid_attr)).to be_valid
    end

    %i[email contact].each do |attr|
      it "is is valid with #{attr} nil" do
        valid_attr[attr] = nil
        expect(described_class.new(valid_attr)).to be_valid
      end
    end

    it 'is invalid with empty info' do
      valid_attr[:contact][:info] = ''
      expect(described_class.new(valid_attr)).to be_invalid
    end

    it 'is valid with empty person' do
      valid_attr[:contact][:person] = ''
      expect(described_class.new(valid_attr)).to be_valid

    it 'is valid with N/D contact info' do
      valid_attr[:contact][:info] = 'N/D'
      expect(described_class.new(valid_attr)).to be_valid
    end

    it 'is invalid with empty description' do
      valid_attr[:description] = ''
      expect(described_class.new(valid_attr)).to be_invalid
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
        nil,
        'https://google.com',
        'foo bar baz',
        nil,
        '',
        '',
        'fulano',
        '(11) 99999-9999'
      ]
    end

    it 'parses correctly' do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(described_class).to receive(:save).and_call_original
      # rubocop:enable RSpec/AnyInstance
      expect { described_class.create_from(valid_sheets) }.not_to raise_error
    end
  end

  context 'with creation methods' do
    it 'creates a correct hash contact when passed correct params' do
      expected = { person: 'Foo', info: 'Bar' }
      contact = described_class.get_contact('Foo', 'Bar')
      expect(contact).to include(expected)
    end

    %i[person info].each do |_attr|
      it 'returns nil contact when contact does not exist' do
        contact = described_class.get_contact('', '')

        expect(contact).to be_nil
      end
    end
  end
end

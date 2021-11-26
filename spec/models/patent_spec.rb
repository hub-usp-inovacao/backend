# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Patent, type: :model do
  let :valid_attr do
    {
      name: 'Modificação operacional de condutivimetro para medida analógica direta',
      summary: 'foo bar baz baz bar baz',
      classification: {
        primary: {
          cip: 'G - Física',
          subarea: 'G01 - Medição; teste'
        },
        secondary: {
          cip: 'G - Física',
          subarea: 'G01 - Medição; teste'
        }
      },
      ipcs: %w[G01N002706 G01N003318 G01R002722],
      owners: ['Univ. São Paulo'],
      status: 'Domínio Público',
      url: 'https://www.derwentinnovation.com/tip-innovation/externalLink.do?data=eEO7KvKuA%2BZmPC8utuUqQr7lxA0syEOxG1yqA8aIDa%2FHR0Yfnr7aHsH4I3OaAA37ytEXegSSxUP88PZ%2FJk5CQ0F4IIj6EeeZd%2Fly4xNtak9D2Ijuz2cF9Rr1PHQZYuFqg%2FYNe5%2BU%2F6zBxsQ4e9T6wcUaS6C2iUdS1Quy3oxeQInFAX0jXNFh7mzwKSn8aGG4VzpPdJ%2BnHJF%2BMRoOami4RIjq7tjlEE9JGV%2BNkVHomAIZzfHxG4IyIQtFFyh2ZmyyAvka04VEc0mfBtPA5xYZ5A%3D%3D&code=4c2c69ca2e3d1b11af22306222240f03',
      inventors: ['Lelio Favaretto'],
      countries_with_protection: ['Brasil'],
      photo: 'https://drive.google.com/uc?export=view&id=1cmsUahKZ6fMsat4P9QFWyOM9T9CWA-cw'
    }
  end

  describe 'Validations' do
    it 'is valid with valid attributes' do
      patent = described_class.new valid_attr
      expect(patent).to be_valid
    end

    %i[name classification ipcs owners status].each do |field|
      it "is invalid without #{field}" do
        attrs = valid_attr.clone
        attrs.delete(field)

        patent = described_class.new attrs
        expect(patent).to be_invalid
      end
    end

    it 'is invalid with a wrong shaped classification' do
      attr = valid_attr.clone
      attr[:classification] = {
        primary: { foo: 1 },
        tertiary: 'baz'
      }

      patent = described_class.new attr
      expect(patent).to be_invalid
    end

    it 'is invalid with a wrong status' do
      attr = valid_attr.clone
      attr[:status] = 'foo'

      patent = described_class.new attr
      expect(patent).to be_invalid
    end

    it 'is invalid with malformed classification' do
      attr = valid_attr.clone
      attr[:classification][:primary] = {
        cip: 'A- Malformed',
        subarea: 'A01 - Well Formed'
      }
      patent = described_class.new attr
      expect(patent).to be_invalid
    end

    it 'is invalid with malformed IPCs' do
      attr = valid_attr.clone
      attr[:ipcs] = ['ABCD000000']
      patent = described_class.new attr
      expect(patent).to be_invalid
    end

    it 'is invalid without a photo id' do
      attr = valid_attr.clone
      attr[:photo] = 'N/D'
      patent = described_class.new attr
      expect(patent).to be_invalid
    end
  end

  describe 'Creation methods' do
    it 'creates a correct classification when secondary classification does not exist' do
      mocked_row = ['G - Física', 'G01 - Medição', 'N/D', 'N/D']
      expect = {
        primary: {
          cip: 'G - Física',
          subarea: 'G01 - Medição'
        }
      }
      classification = described_class.classify(mocked_row)
      expect(classification).to include(expect)
    end
  end
end

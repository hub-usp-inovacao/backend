# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanyUpdate, type: :model do
  let(:valid_attr) do
    {
      cnpj: '14.380.200/0001-21',
      name: 'Fulano',
      partners_values: [
        {
          name: 'Paulo',
          phone: '11 999999999',
          email: 'Foo@bar.com',
          bond: 'Docente',
          nusp: '11111111',
          unity: 'Museu Paulista - MP'
        }
      ],
      company_values: [
        { Foo: 'Bar' }
      ],
      dna_values: {
        wants_dna: true,
        name: 'Fulano',
        email: 'fulano@mail.com'
      }
    }
  end

  it 'is valid with valid attributes' do
    company_updated = described_class.new(valid_attr)
    expect(company_updated).to be_valid
  end

  %i[company_values partners_values].each do |att|
    it "is valid if just #{att} does not exist" do
      attr_copy = valid_attr.clone
      attr_copy.delete(att)
      company_updated = described_class.new(attr_copy)
      expect(company_updated).to be_valid
    end
  end

  it 'is invalid if both company_values and partners_values do not exist' do
    attr_copy = valid_attr.clone
    attr_copy.delete(:company_values)
    attr_copy.delete(:partners_values)
    company_updated = described_class.new(attr_copy)
    expect(company_updated).to be_invalid
  end

  it 'is invalid with invalid cnpj' do
    invalid_attr = valid_attr.clone
    invalid_attr[:cnpj] = '11275297'
    company_updated = described_class.new(invalid_attr)
    expect(company_updated).to be_invalid
  end

  it "is invalid when the elements in company_values aren't Hash type" do
    invalid_attr = valid_attr.clone
    invalid_attr[:company_values] = [123]
    company_updated = described_class.new(invalid_attr)
    expect(company_updated).to be_invalid
  end

  it "is invalid when the elements in partners_values aren't Hash type" do
    invalid_attr = valid_attr.clone
    invalid_attr[:partners_values] = [123]
    company_updated = described_class.new(invalid_attr)
    expect(company_updated).to be_invalid
  end

  it 'is invalid if a partner has a invalid bond' do
    invalid_attr = valid_attr.clone
    invalid_attr[:partners_values][0][:bond] = 'Foo'
    company_updated = described_class.new(invalid_attr)
    expect(company_updated).to be_invalid
  end

  it 'is invalid with inconsistent dna_values' do
    invalid_attr = valid_attr.clone
    invalid_attr[:dna_values] = { wants_dna: true }
    expect(described_class.new(invalid_attr)).to be_invalid
  end
end

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
          bond: 'Aluno ou ex-aluno de graduação',
          nusp: '11111111',
          unity: 'Escola de Comunicação e Artes - ECA'
        }
      ],
      company_values: [
        { Foo: 'Bar' }
      ]
    }
  end

  it 'is valid with valid attributes' do
    company_updated = described_class.new(valid_attr)
    expect(company_updated).to be_valid
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

  it 'is invalid when the partner does not have the basic attributes' do
    invalid_attr = valid_attr.clone
    invalid_attr[:partners_values][0].delete(:name)
    company_updated = described_class.new(invalid_attr)
    expect(company_updated).to be_invalid
  end

  it 'is invalid if a partner has a invalid bond' do
    invalid_attr = valid_attr.clone
    invalid_attr[:partners_values][0][:bond] = 'Foo'
    company_updated = described_class.new(invalid_attr)
    expect(company_updated).to be_invalid
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanyUpdate, type: :model do
  it 'is valid with valid attributes' do
    valid_attr = { cnpj: '14.380.200/0001-21', new_values: [{ Foo: 'Bar' }] }
    company_updated = described_class.new(valid_attr)
    expect(company_updated).to be_valid
  end

  it 'is invalid with invalid cnpj' do
    invalid_attr = { cnpj: '11275297', new_values: [{ Foo: 'Bar' }] }
    company_updated = described_class.new(invalid_attr)
    expect(company_updated).to be_invalid
  end

  it "is invalid when the elements of the array aren't Hash type" do
    invalid_attr = { cnpj: '14.380.200/0001-21', new_values: [123] }
    company_updated = described_class.new(invalid_attr)
    expect(company_updated).to be_invalid
  end
end

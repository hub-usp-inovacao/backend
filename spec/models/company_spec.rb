# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  let :valid_attr do
    {
      name: "Uber 99",
      year: "2019",
      services: "foo bar baz",
      incubated: false,
      emails: [
        "foo@exmaple.com",
        "bar@exmaple.com",
      ],
      ecosystems: [
        "ESALQTec",
      ],
      description: {
        long: "foo bar baz",
      },
      allowed: true,
      address: {
        cep: "13414-157",
        city: [ "Piracicaba" ],
        neightborhood: "Loteamento Santa Rosa",
        state: "São Paulo",
        venue: "Rua Cezira Giovanni",
      },
      active: true,
      url: "https://techagr.com",
      technologies: [ "foo bar baz" ],
      phones: ["(11) 987288877"],
      logo: "https://drive.google.com/...",
      companySize: ["Média Empresa"],
      classification: {
        major: "Comércio e Serviços",
        minor: "Informação e Comunicação"
      }
    }
  end

  it 'is valid with valid attributes' do
    company = described_class.new valid_attr
    expect(company).to be_valid
  end

  %i[name year emails description incubated ecosystems services address].each do |required|
    it "is invalid without #{required}" do
      attrs = valid_attr.except required
      company = described_class.new attrs
      expect(company).to be_invalid
    end
  end

  ["", "a", "a" * 101].each do |wrong_sized_name|
    it 'is invalid with wrong sized name' do
      attrs = valid_attr
      attrs[:name] = wrong_sized_name
      company = described_class.new attrs
      expect(company).to be_invalid
    end
  end

  ["dois mil", "124", "2022"].each do |invalid_year|
    it 'is invalid with invalid years' do
      attrs = valid_attr
      attrs[:year] = invalid_year
      company = described_class.new attrs
      expect(company).to be_invalid
    end
  end
end

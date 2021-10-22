# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  let :valid_attr do
    {
      cnpj: '12.123.123/0001-21',
      name: 'Uber 99',
      year: '2019',
      services: 'foo bar baz',
      incubated: false,
      emails: [
        'foo@exmaple.com',
        'bar@exmaple.com'
      ],
      ecosystems: [
        'ESALQTec'
      ],
      description: {
        long: 'foo bar baz'
      },
      allowed: true,
      address: {
        cep: '13414-157',
        city: ['Piracicaba'],
        neightborhood: 'Loteamento Santa Rosa',
        state: 'São Paulo',
        venue: 'Rua Cezira Giovanni'
      },
      active: true,
      url: 'https://techagr.com',
      technologies: ['foo bar baz'],
      phones: ['(11) 987288877'],
      logo: 'https://drive.google.com/...',
      companySize: ['Média Empresa'],
      classification: {
        major: 'Comércio e Serviços',
        minor: 'Informação e Comunicação'
      },
      partners: [
        {
          name: 'Fulano de Tal',
          nusp: '1234567',
          bond: 'Pesquisador',
          unity: 'Faculdade de Odontologia de Bauru - FOB',
          email: 'fulano@detal.com',
          phone: '(11) 99999-9999'
        },
        {
          name: '',
          nusp: '',
          bond: '',
          unity: '',
          email: '',
          phone: ''
        },
        {
          name: '',
          nusp: '',
          bond: '',
          unity: '',
          email: '',
          phone: ''
        },
        {
          name: '',
          nusp: '',
          bond: '',
          unity: '',
          email: '',
          phone: ''
        },
        {
          name: '',
          nusp: '',
          bond: '',
          unity: '',
          email: '',
          phone: ''
        }
      ],
      corporate_name: 'razão social',
      number_of_clt_employees: 1,
      number_of_pj_colaborators: 1,
      number_of_interns: 1,
      received_investments: false,
      investiments: [],
      investiments_values: {
        own: '',
        angel: '',
        venture_capital: '',
        private_equity: '',
        pipe_fapesp: '',
        other: ''
      }
    }
  end

  it 'is valid with valid attributes' do
    company = described_class.new valid_attr
    expect(company).to be_valid
  end

  %i[cnpj name year emails description incubated ecosystems services address
     corporate_name].each do |required|
    it "is invalid without #{required}" do
      attrs = valid_attr.except required
      company = described_class.new attrs
      expect(company).to be_invalid
    end
  end

  ['', 'a', 'a' * 101].each do |wrong_sized_name|
    it 'is invalid with wrong sized name' do
      attrs = valid_attr
      attrs[:name] = wrong_sized_name
      company = described_class.new attrs
      expect(company).to be_invalid
    end
  end

  ['dois mil', '124', '2022'].each do |invalid_year|
    it 'is invalid with invalid years' do
      attrs = valid_attr
      attrs[:year] = invalid_year
      company = described_class.new attrs
      expect(company).to be_invalid
    end
  end

  %i[url logo].each do |url_like|
    it "is invalid with invalid #{url_like}" do
      attrs = valid_attr
      attrs[url_like] = 'foo bar baz'
      company = described_class.new attrs
      expect(company).to be_invalid
    end
  end

  [
    { attr: :companySize, value: ['foo bar baz'] },
    { attr: :classification, value: { value: '13' } },
    { attr: :cnpj, value: '123.123.123-12' }
  ].each do |ctx|
    it "is invalid with a wrong #{ctx[:attr]}" do
      attrs = valid_attr
      attrs[ctx[:attr]] = ctx[:value]
      company = described_class.new attrs
      expect(company).to be_invalid
    end
  end
end

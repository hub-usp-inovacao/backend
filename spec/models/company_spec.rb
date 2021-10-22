# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  let :valid_attr do
    {
      cnpj: '12.123.123/0001-21',
      name: 'Uber 99',
      year: '2019',
      services: %w[foo bar baz],
      incubated: 'Não',
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
        neighborhood: 'Loteamento Santa Rosa',
        state: 'São Paulo',
        venue: 'Rua Cezira Giovanni'
      },
      active: true,
      url: 'https://techagr.com',
      technologies: ['foo bar baz'],
      phones: ['(11) 987288877'],
      logo: 'https://drive.google.com/...',
      companySize: ['Média Empresa'],
      cnae: '66.13-4-00',
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
      corporate_name: 'razão social'
    }
  end

  describe 'Validations' do
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

    it 'is invalid with a wrong classification' do
      attrs = valid_attr
      attrs[:classification] = { value: '13' }
      company = described_class.new attrs
      expect(company).to be_invalid
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

    describe 'partners validation' do
      it 'fails when the list is empty' do
        attrs = valid_attr.clone
        attrs[:partners] = []
        company = described_class.new attrs
        expect(company).to be_invalid
      end

      describe 'partner with wrong attributes' do
        let :partners_overwrite_attrs do
          attrs = valid_attr.clone
          attrs[:partners] = [{
            name: 'Fulano de Tal',
            nusp: '1234567',
            bond: 'Pesquisador',
            unity: 'Faculdade de Odontologia de Bauru - FOB',
            email: 'fulano@detal.com',
            phone: '(11) 99999-9999'
          }]

          attrs
        end

        it 'fails when the only partner has wrong unity' do
          attrs = partners_overwrite_attrs.clone
          attrs[:partners][0][:unity] = 'IME'
          company = described_class.new attrs
          expect(company).to be_invalid
        end

        it 'fails when the only partner has wrong bond' do
          attrs = partners_overwrite_attrs.clone
          attrs[:partners][0][:bond] = 'james'
          company = described_class.new attrs
          expect(company).to be_invalid
        end
      end
    end
  end

  describe 'Creation methods' do
    [{
      major: 'Comércio e Serviços',
      minor: 'Informação e Comunicação'
    }, {
      major: 'Indústria de Transformação',
      minor: 'Produtos Diversos'
    }].each do |classification|
      %w[0 5 50 5000].each do |employees|
        it 'creates a correct company size' do
          sizes = described_class.size(employees, '', classification)
          expect(sizes).to be_all { |size| company_sizes.include?(size) }
        end
      end
    end

    it 'creates a correct unicorn company size' do
      classification = valid_attr[:classification]
      employees = '0'
      sizes = described_class.size(employees, 'Unicórnio', classification)
      expect(sizes).to be_all { |size| company_sizes.include?(size) }
    end
  end
end

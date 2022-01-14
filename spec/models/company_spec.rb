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
      corporate_name: 'razão social',
      collaborators_last_updated_at: DateTime.now,
      investments_last_updated_at: DateTime.now,
      revenues_last_updated_at: DateTime.now
    }
  end

  describe 'Validations' do
    it 'is valid with valid attributes' do
      company = described_class.new valid_attr
      expect(company).to be_valid
    end

    %i[cnpj name year description incubated ecosystems services address
       corporate_name].each do |required|
      it "is invalid without #{required}" do
        attrs = valid_attr.except required
        company = described_class.new attrs
        expect(company).to be_invalid
      end
    end

    it 'is invalid with a malformed cnpj' do
      valid_attr[:cnpj] = '123.123'
      expect(described_class.new(valid_attr)).to be_invalid
    end

    it 'is valid with a foreign indicator cnpj' do
      valid_attr[:cnpj] = 'Exterior9'
      expect(described_class.new(valid_attr)).to be_valid
    end

    it 'is valid with an empty phone list' do
      valid_attr[:phones] = []
      expect(described_class.new(valid_attr)).to be_valid
    end

    ['dois mil', '124', '2050'].each do |invalid_year|
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

      it 'does not fail when the list is empty' do
        attrs = valid_attr.clone
        attrs[:partners] = []
        company = described_class.new attrs
        expect(company).to be_valid
      end

      it 'does not fail when the only partner has wrong unity' do
        attrs = partners_overwrite_attrs.clone
        attrs[:partners][0][:unity] = 'IME'
        company = described_class.new attrs
        expect(company).to be_valid
      end

      it 'does not fail when the only partner has wrong bond' do
        attrs = partners_overwrite_attrs.clone
        attrs[:partners][0][:bond] = 'james'
        company = described_class.new attrs
        expect(company).to be_valid
      end
    end
  end

  describe 'Creation methods' do
    [{ employees: 0, expect: ['Não Informado'] },
     { employees: 5, expect: ['Microempresa'] },
     { employees: 10, expect: ['Pequena Empresa'] },
     { employees: 50, expect: ['Média Empresa'] },
     { employees: 100, expect: ['Grande Empresa'] }].each do |hash|
      it 'creates a correct company size when this is not an industrial business' do
        classification = {
          major: 'Comércio e Serviços',
          minor: 'Informação e Comunicação'
        }
        sizes = described_class.size(hash[:employees], '', classification)
        expect(sizes).to be_all { |size| hash[:expect].include?(size) }
      end
    end

    [{ employees: 0, expect: ['Não Informado'] },
     { employees: 5, expect: ['Microempresa'] },
     { employees: 20, expect: ['Pequena Empresa'] },
     { employees: 100, expect: ['Média Empresa'] },
     { employees: 500, expect: ['Grande Empresa'] }].each do |hash|
      it 'creates a correct company size when this is an industrial business' do
        classification = {
          major: 'Indústria de Transformação',
          minor: 'Produtos Diversos'
        }
        sizes = described_class.size(hash[:employees], '', classification)
        expect(sizes).to be_all { |size| hash[:expect].include?(size) }
      end
    end

    it 'creates a correct unicorn company size' do
      classification = valid_attr[:classification]
      employees = '0'
      sizes = described_class.size(employees, 'Unicórnio', classification)
      expect(sizes).to be_all { |size| ['Unicórnio', 'Não Informado'].include?(size) }
    end

    [{ cnae: '46.00-0-00', expect: {
      major: 'Comércio e Serviços',
      minor: 'Comércio por Atacado, exceto Veículos Automotores e Motocicletas'
    } },
     { cnae: '01.00-0-00', expect: {
       major: 'Agricultura, Pecuária, Pesca e Extrativismo',
       minor: 'Agricultura, Pecuária, Produção Florestal, Pesca e Aquicultura'
     } }].each do |hash|
      it 'creates a correct classification' do
        classification = described_class.classify(hash[:cnae])
        expect(classification).to include(hash[:expect])
      end
    end

    ['', '89.00-0-00', '371.00-0-00'].each do |cnae|
      it 'creates an empty classification when used an invalid cnae' do
        expect = {
          major: '',
          minor: ''
        }
        classification = described_class.classify(cnae)
        expect(classification).to include(expect)
      end
    end

    it 'returns N/D if the row is empty' do
      expect(described_class.timestamp('')).to eql('N/D')
    end

    it 'returns the proper DateTime when a timestamp is given' do
      y = 2020
      m = 4
      d = 21
      dt = DateTime.new y, m, d
      ts = "#{d}/#{m}/#{y}"

      expect(described_class.timestamp(ts)).to eql(dt)
    end
  end
end

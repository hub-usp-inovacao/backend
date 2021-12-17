# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanyUpdate, type: :model do
  let(:valid_attr) do
    {
      created_at: DateTime.new(2020, 1, 1).getutc,
      cnpj: '14.380.200/0001-21',
      name: 'Fulano',
      partners_values: [
        {
          name: 'Paulo',
          phone: '11 999999999',
          email: 'Foo@bar.com',
          bond: 'Docente',
          nusp: '11111111',
          unity: 'Museu Paulista - MP',
          role: 'CEO'
        }
      ],
      company_values: {
        'Razão social da empresa': 'Fulano inc.',
        'Ano de fundação': 1990,
        'cnae': '85.29-4-15',
        'Telefone comercial': ['11 999999999'],
        'Emails': ['Foo@foo.com', 'Bar@bar.com'],
        'Endereço': 'Rua do matão, 69',
        'Bairro': 'Butantã',
        'Cidade sede': ['São Paulo'],
        'Estado': 'São Paulo',
        'CEP': '88804-342',
        'Breve descrição': 'faço teste de corno',
        'Produtos e serviços': 'N/D',
        'Tecnologias': 'N/D',
        'Site': 'fulano.com.br',
        'A empresa está ou esteve em alguma incubadora ou Parque tecnológico': 'Não',
        'Em qual incubadora?': [],
        'Redes sociais': 'fb.com/fulano',
        'Número de funcionários contratados como CLT': 2,
        'Número de colaboradores contratados como Pessoa Jurídica (PJ)': 3,
        'Número de estagiários/bolsistas contratados': 1,
        'A empresa recebeu investimento?': 'Não',
        'Investimentos': '',
        'Valor do investimento próprio (R$)': 'R$ 0,00',
        'Valor do investimento-anjo (R$)': 'R$ 0,00',
        'Valor do Venture Capital (R$)': 'R$ 0,00',
        'Valor do Private Equity (R$)': 'R$0,00',
        'Valor do PIPE-FAPESP (R$)': 'R$ 0,00',
        'Valor de outros investimentos (R$)': 'R$ 0,00',
        'Faturamento': 'R$ 6.666,66',
        'Objetivos de Desenvolvimento Sustentável': 'Sim',
        'Data da última atualização de Colaboradores': '2019',
        'Data da última atualização de Faturamento': '2019',
        'Data da última atualização de Investimento': '2019'
      },
      dna_values: {
        wants_dna: true,
        name: 'Fulano',
        email: 'fulano@mail.com'
      },
      truthful_informations: true,
      permission: [
        "Permito o envio de e-mails para ser avisado sobre eventos e oportunidades relevantes \
à empresa"
      ]
    }
  end
  let(:valid_csv) do
    <<~MULTILINE
      Carimbo de data/hora,CNPJ,Nome,Razão social da empresa,Ano de fundação,CNAE,Telefone comercial,Emails,\
      Endereço,Bairro,Cidade sede,Estado,CEP,Breve descrição,Produtos e serviços,Tecnologias,_,Site,\
      A empresa está ou esteve em alguma incubadora ou Parque tecnológico,Em qual incubadora?,_,_,\
      Redes sociais,Deseja a marca DNAUSP?,Email,Nome,_,Confirmação,Permissão,\
      Nome do sócio,NUSP,Vínculo,Unidade,Cargo,Email,Telefone,Quantos sócios a empresa possui?,_,_,\
      Nome do sócio,NUSP,Vínculo,Unidade,Email,_,Nome do sócio,NUSP,Vínculo,Unidade,Email,_,\
      Nome do sócio,NUSP,Vínculo,Unidade,Email,_,Nome do sócio,NUSP,Vínculo,Unidade,Email,\
      Número de funcionários contratados como CLT,Número de colaboradores contratados como Pessoa Jurídica (PJ),\
      Número de estagiários/bolsistas contratados,A empresa recebeu investimento?,Investimentos,\
      Valor do investimento próprio (R$),Valor do investimento-anjo (R$),Valor do Venture Capital (R$),\
      Valor do Private Equity (R$),Valor do PIPE-FAPESP (R$),Valor de outros investimentos (R$),Faturamento,\
      _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,Objetivos de Desenvolvimento Sustentável,Data da última atualização de Colaboradores,\
      Data da última atualização de Faturamento,Data da última atualização de Investimento
      #{valid_attr[:created_at]},#{valid_attr[:cnpj]},#{valid_attr[:name]},\
      #{valid_attr[:company_values]['Razão social da empresa'.to_sym]},\
      #{valid_attr[:company_values]['Ano de fundação'.to_sym]},\
      #{valid_attr[:company_values][:cnae]},#{valid_attr[:company_values]['Telefone comercial'.to_sym].join(';')},\
      #{valid_attr[:company_values][:Emails].join(';')},"#{valid_attr[:company_values][:Endereço]}",\
      #{valid_attr[:company_values][:Bairro]},#{valid_attr[:company_values]['Cidade sede'.to_sym].join(';')},\
      #{valid_attr[:company_values][:Estado]},#{valid_attr[:company_values][:CEP]},\
      #{valid_attr[:company_values]['Breve descrição'.to_sym]},#{valid_attr[:company_values]['Produtos e serviços'.to_sym]},\
      #{valid_attr[:company_values][:Tecnologias]},"",#{valid_attr[:company_values][:Site]},\
      #{valid_attr[:company_values]['A empresa está ou esteve em alguma incubadora ou Parque tecnológico'.to_sym]},\
      "","","",#{valid_attr[:company_values]['Redes sociais'.to_sym]},\
      Sim,#{valid_attr[:dna_values][:email]},#{valid_attr[:dna_values][:name]},"",\
      Sim,#{valid_attr[:permission].join(';')},\
      #{valid_attr[:partners_values][0][:name]},#{valid_attr[:partners_values][0][:nusp]},\
      #{valid_attr[:partners_values][0][:bond]},#{valid_attr[:partners_values][0][:unity]},\
      #{valid_attr[:partners_values][0][:role]},#{valid_attr[:partners_values][0][:email]},\
      #{valid_attr[:partners_values][0][:phone]},#{valid_attr[:partners_values].length},"","",\
      "","","","","","","","","","","","","","","","","","","","","","","",\
      #{valid_attr[:company_values]['Número de funcionários contratados como CLT'.to_sym]},\
      #{valid_attr[:company_values]['Número de colaboradores contratados como Pessoa Jurídica (PJ)'.to_sym]},\
      #{valid_attr[:company_values]['Número de estagiários/bolsistas contratados'.to_sym]},\
      #{valid_attr[:company_values]['A empresa recebeu investimento?'.to_sym]},"",\
      "#{valid_attr[:company_values]['Valor do investimento próprio (R$)'.to_sym]}",\
      "#{valid_attr[:company_values]['Valor do investimento-anjo (R$)'.to_sym]}",\
      "#{valid_attr[:company_values]['Valor do Venture Capital (R$)'.to_sym]}",\
      "#{valid_attr[:company_values]['Valor do Private Equity (R$)'.to_sym]}",\
      "#{valid_attr[:company_values]['Valor do PIPE-FAPESP (R$)'.to_sym]}",\
      "#{valid_attr[:company_values]['Valor de outros investimentos (R$)'.to_sym]}",\
      "#{valid_attr[:company_values][:Faturamento]}","","","","","","","","","","","","","","","",\
      #{valid_attr[:company_values]['Objetivos de Desenvolvimento Sustentável'.to_sym]},\
      #{valid_attr[:company_values]['Data da última atualização de Colaboradores'.to_sym]},\
      #{valid_attr[:company_values]['Data da última atualização de Faturamento'.to_sym]},\
      #{valid_attr[:company_values]['Data da última atualização de Investimento'.to_sym]}
    MULTILINE
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

  it 'is invalid when truthful_informations is false' do
    valid_attr[:truthful_informations] = false
    expect(described_class.new(valid_attr)).to be_invalid
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

  it 'is invalid with invalid partner email' do
    invalid_attr = valid_attr.clone
    invalid_attr[:partners_values][0][:email] = 'Foo'
    company_updated = described_class.new(invalid_attr)
    expect(company_updated).to be_invalid
  end

  it 'is invalid with inconsistent dna_values' do
    invalid_attr = valid_attr.clone
    invalid_attr[:dna_values] = { wants_dna: true }
    expect(described_class.new(invalid_attr)).to be_invalid
  end

  it 'generates a correct csv file' do
    company_updated = described_class.new(valid_attr)
    allow(described_class).to receive(:all).and_return([company_updated])
    expect(described_class.to_csv).to eql(valid_csv)
  end

  context 'with different partner_values' do
    it "is invalid when the elements aren't Hash type" do
      valid_attr[:partners_values] = [123]
      expect(described_class.new(valid_attr)).to be_invalid
    end

    it 'is invalid when hash contains unexpected attributes' do
      valid_attr[:partners_values][0][:foo] = 'bar'
      expect(described_class.new(valid_attr)).to be_invalid
    end

    it 'is valid if a partner has unknown bond' do
      valid_attr[:partners_values][0][:bond] = 'Foo'
      expect(described_class.new(valid_attr)).to be_valid
    end

    it 'is valid if a partner has an unknown unity' do
      valid_attr[:partners_values][0][:unity] = 'Foo'
      expect(described_class.new(valid_attr)).to be_valid
    end
  end
end

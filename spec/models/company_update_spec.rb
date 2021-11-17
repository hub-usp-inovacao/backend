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
      company_values: {
        Foo: 'Bar',
        'Razão social da empresa': 'Fulano inc.'
      },
      dna_values: {
        wants_dna: true,
        name: 'Fulano',
        email: 'fulano@mail.com'
      },
      truthful_informations: true,
      permission: [
        "Permito o envio de e-mails para ser avisado sobre eventos e oportunidades \
relevantes à empresa"
      ]
    }
  end

  let(:valid_csv) do
    <<~MULTILINE
      CNPJ,Nome,Razão social da empresa,Ano de fundação,CNAE,Emails,Endereço,Bairro,Cidade sede,\
      Estado,CEP,Breve descrição,Site,Tecnologias,Produtos e serviços,\
      Objetivos de Desenvolvimento Sustentável,Redes sociais,Número de funcionários contratados como CLT,\
      Número de colaboradores contratados como Pessoa Jurídica (PJ),Número de estagiários/bolsistas contratados,\
      A empresa está ou esteve em alguma incubadora ou Parque tecnológico,A empresa recebeu investimento?,\
      Investimentos,Valor do investimento próprio (R$),Valor do investimento-anjo (R$),\
      Valor do Venture Capital (R$),Valor do Private Equity (R$),Valor do PIPE-FAPESP (R$),\
      Valor de outros investimentos (R$),Faturamento,Deseja a marca DNAUSP?,Nome,Email,\
      Nome do sócio,Email,Vínculo,Unidade,NUSP,Nome do sócio,Email,Vínculo,Unidade,NUSP,\
      Nome do sócio,Email,Vínculo,Unidade,NUSP,Nome do sócio,Email,Vínculo,Unidade,NUSP,\
      Nome do sócio,Email,Vínculo,Unidade,NUSP,Permissão,Confirmação
      #{valid_attr[:cnpj]},#{valid_attr[:name]},#{valid_attr[:company_values]['Razão social da empresa'.to_sym]},\
      "","","","","","","","","","","","","","","","","","","","","","","","","","","",\
      #{valid_attr[:dna_values][:wants_dna]},#{valid_attr[:dna_values][:name]},#{valid_attr[:dna_values][:email]},\
      #{valid_attr[:partners_values][0][:name]},#{valid_attr[:partners_values][0][:email]},\
      #{valid_attr[:partners_values][0][:bond]},#{valid_attr[:partners_values][0][:unity]},\
      #{valid_attr[:partners_values][0][:nusp]},"","","","","","","","","","","","","","","","","","","","",\
      Permito o envio de e-mails para ser avisado sobre eventos e oportunidades relevantes à empresa,true
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

  it 'generates a correct csv file' do
    company_updated = described_class.new(valid_attr)
    allow(described_class).to receive(:all).and_return([company_updated])
    expect(described_class.to_csv).to eql(valid_csv)
  end
end

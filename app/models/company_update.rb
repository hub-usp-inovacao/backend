# frozen_string_literal: true

require 'csv'

class CompanyUpdate
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :cnpj, type: String
  field :partners_values, type: Array
  field :company_values, type: Hash
  field :delivered, type: Boolean, default: false
  field :dna_values, type: Hash

  validates :name, :cnpj, presence: true
  validates :cnpj,
            format: { with: %r{\A\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}\z},
                      message: 'must be a valid cnpj' }
  validate :validate_partners_values, :validate_values_presence, :validate_dna

  def valid_name(name)
    !name.nil? &&
      name.is_a?(String) &&
      name.size.positive?
  end

  def valid_email(email)
    rgx = /\A[a-z0-9.]+@[a-z0-9]+\.[a-z]+(\.[a-z]+)?\Z/

    !email.nil? &&
      rgx.match?(email)
  end

  def consistent(dna)
    !dna[:wants_dna] || (valid_name(dna[:name]) && valid_email(dna[:email]))
  end

  def validate_dna
    is_valid = !dna_values.nil? &&
               dna_values.is_a?(Hash) &&
               consistent(dna_values)

    errors.add(:dna_values, 'invalid') unless is_valid
  end

  def validate_partner(partner)
    return false unless partner.is_a? Hash

    bond_valid = partner[:bond].size.zero? ||
                 company_partner_bonds.include?(partner[:bond])

    unity_valid = partner[:unity].size.zero? ||
                  unities.include?(partner[:unity])

    bond_valid && unity_valid
  end

  def validate_partners_values
    return unless partners_values
    return if partners_values.is_a?(Array) && partners_values.all? do |partner|
                validate_partner(partner)
              end

    errors.add(:partners_values, :invalid)
  end

  def validate_values_presence
    return if company_values || partners_values

    errors.add(:company_values, 'Company_values e Partners_values não podem ser ambos nulos')
    errors.add(:partners_values, 'Company_values e Partners_values não podem ser ambos nulos')
  end

  def self.csv_columns(max_partners)
    attributes = ['CNPJ', 'Nome', 'Razão social da empresa',
                  'Ano de fundação', 'CNAE', 'Emails', 'Endereço', 'Bairro',
                  'Cidade sede', 'Estado', 'CEP', 'Breve descrição', 'Site', 'Tecnologias',
                  'Produtos e serviços', 'Objetivos de Desenvolvimento Sustentável',
                  'Redes sociais', 'Número de funcionários contratados como CLT',
                  'Número de colaboradores contratados como Pessoa Jurídica (PJ)',
                  'Número de estagiários/bolsistas contratados',
                  'A empresa está ou esteve em alguma incubadora ou Parque tecnológico',
                  'A empresa recebeu investimento?', 'Investimentos',
                  'Valor do investimento próprio (R$)', 'Valor do investimento-anjo (R$)',
                  'Valor do Venture Capital (R$)', 'Valor do Private Equity (R$)',
                  'Valor do PIPE-FAPESP (R$)', 'Valor de outros investimentos (R$), Financiamento',
                  'Deseja a marca DNAUSP?', 'Nome', 'Email']

    attributes.concat(['Nome do sócio', 'Email', 'Vínculo', 'Unidade', 'NUSP'] * max_partners)
  end

  def self.get_value(value)
    value.nil? ? '' : value
  end

  def self.to_csv
    max_partners = 5
    attributes = csv_columns(max_partners)
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |company|
        row = []
        row.concat(%w[cnpj name].map { |attr| company.send(attr) })
        row.concat(attributes[2..29].map { |attr| get_value(company.send('company_values')[attr]) })
        row.concat(%w[wants_dna name email].map do |attr|
                     get_value(company.send('dna_values')[attr])
                   end)

        partners = get_value(company.send('partners_values'))
        (0..max_partners - 1).each do |i|
          if i < partners.length
            partner = partners[i]
            row.concat(%w[name email bond unity nusp].map do |attr|
                         get_value(partner[attr])
                       end)
          else
            row.concat([''] * 5)
          end
        end
        csv << row
      end
    end
  end
end

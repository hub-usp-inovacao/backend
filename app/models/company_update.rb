# frozen_string_literal: true

require 'csv'

class CompanyUpdate
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :cnpj, type: String
  field :partners_values, type: Array
  field :company_values, type: Hash
  field :dna_values, type: Hash
  field :delivered, type: Boolean, default: false
  field :permission, type: Array
  field :truthful_informations, type: Boolean

  validates :name, :cnpj, :permission, :truthful_informations, presence: true
  validates :cnpj,
            format: { with: %r{\A(\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}|Exterior\d*)\z},
                      message: 'mal formatado. Exemplo: dd.ddd.ddd/dddd-dd ou Exterior12' }
  validate :validate_partners_values, :validate_values_presence, :validate_dna, :validate_permission

  def validate_permission
    valids = [
      'Permito a divulgação das informações públicas na plataforma Hub USPInovação',
      "Permito o envio de e-mails para ser avisado sobre eventos e oportunidades relevantes \
à empresa",
      "Permito a divulgação das informações públicas na plataforma Hub USPInovação e também \
para unidades da USP"
    ]

    is_valid = !permission.nil? &&
               permission.all? { |p| valids.include? p }

    errors.add(:permission, 'inválida. Selecione pelo menos uma opção') unless is_valid
  end

  def valid_name(name)
    return true if !name.nil? &&
      name.is_a?(String) &&
      name.size.positive?

      errors.add(:dna_values, ': nome inválido')
      false
  end

  def valid_email(email)
    rgx = /\A[a-z0-9.]+@[a-z0-9]+\.[a-z]+(\.[a-z]+)?\Z/

    return true if !email.nil? &&
      rgx.match?(email)

    errors.add(:dna_values, ': email inválido')
    false
  end

  def consistent(dna)
    !dna[:wants_dna] || (valid_name(dna[:name]) && valid_email(dna[:email]))
  end

  def validate_dna
    is_valid = !dna_values.nil? &&
               dna_values.is_a?(Hash)
               

    errors.add(:dna_values, ': Dados em formato inválido') unless is_valid

    consistent(dna_values)
  end

  def validate_partner(partner)
    return false unless partner.is_a? Hash

    expected_syms = %i[name nusp bond email phone unity]
    expected_strs = %w[name nusp bond email phone unity]

    partner.keys.sort.eql?(expected_syms.sort) ||
      partner.keys.sort.eql?(expected_strs.sort)
  end

  def validate_partners_values
    return if partners_values.nil?

    is_valid = partners_values.is_a?(Array) &&
               partners_values.all? do |partner|
                 validate_partner(partner)
               end

    errors.add(:partners_values, ': Cada sócio pode possuir somente os seguintes atributos: nome, NUSP, vínculo, email, telefone e unidade') unless is_valid
  end

  def validate_values_presence
    return if company_values || partners_values

    errors.add(:company_values, ': Os valores da empresa e dos sócios não podem ser ambos nulos')
    errors.add(:partners_values, ': Os valores da empresa e dos sócios não podem ser ambos nulos')
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
                  'Valor do PIPE-FAPESP (R$)', 'Valor de outros investimentos (R$)',
                  'Faturamento', 'Deseja a marca DNAUSP?', 'Nome', 'Email']

    attributes.concat(['Nome do sócio', 'Email', 'Vínculo', 'Unidade', 'NUSP'] * max_partners)
    attributes.concat(%w[Permissão Confirmação])
  end

  def self.sanitize_value(value)
    value.nil? ? '' : value
  end

  def self.get_data_from(attributes, from)
    attributes.map do |attr|
      value = if from.is_a?(Hash)
                from[attr.to_sym]
              else
                from.send(attr)
              end
      sanitize_value(value)
    end
  end

  def self.get_partners_data_from(max_partners, attributes, from)
    result = []
    partners = sanitize_value(from)
    (0...max_partners).each do |i|
      if i < partners.length
        partner = partners[i]
        result.concat(get_data_from(attributes, partner))
      else
        result.concat([''] * 5)
      end
    end
    result
  end

  def self.to_csv
    max_partners = ENV['CSV_MAX_PARTNERS'] || 5
    attributes = csv_columns(max_partners)
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |company|
        row = []

        row.concat(get_data_from(%w[cnpj name], company))
        company_attrs = attributes[2..29]
        row.concat(get_data_from(company_attrs, company.send('company_values')))
        row.concat(get_data_from(%w[wants_dna name email], company.send('dna_values')))
        row.concat(get_partners_data_from(max_partners, %w[name email bond unity nusp],
                                          company.send('partners_values')))
        row << company.permission.join(';')
        row << company.truthful_informations

        csv << row
      end
    end
  end
end

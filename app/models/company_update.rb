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
  validate :validate_partners_values, :validate_values_presence, :validate_dna,
           :validate_permission, :validate_truthful

  def validate_truthful
    is_valid = truthful_informations

    errors.add(:truthful_informations, :invalid) unless is_valid
  end

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

    if is_valid
      consistent(dna_values)
    else
      errors.add(:dna_values, ': Dados em formato inválido')
    end
  end

  def validate_partner(partner)
    return false unless partner.is_a? Hash

    expected_syms = %i[name nusp bond email phone unity role]
    expected_strs = %w[name nusp bond email phone unity role]

    partner.keys.sort.eql?(expected_syms.sort) ||
      partner.keys.sort.eql?(expected_strs.sort)
  end

  def validate_email(email, index)
    is_valid = email.match?(URI::MailTo::EMAIL_REGEXP)

    errors.add(:partner_values, ": #{index + 1}º sócio possui um email inválido.") unless is_valid
  end

  def validate_partners_values
    return if partners_values.nil?

    is_valid = partners_values.is_a?(Array) &&
               partners_values.all? do |partner|
                 validate_partner(partner)
               end

    if is_valid
      partners_values.each_with_index { |partner, i| validate_email(partner[:email], i) }
    else
      error_message = <<~MULTILINE
        : Cada sócio pode possuir somente os seguintes atributos: nome, NUSP, vínculo, email,\
        telefone, unidade e cargo
      MULTILINE
      errors.add(:partners_values, error_message)
    end
  end

  def validate_values_presence
    return if company_values || partners_values

    errors.add(:company_values, ': Os valores da empresa e dos sócios não podem ser ambos nulos')
    errors.add(:partners_values, ': Os valores da empresa e dos sócios não podem ser ambos nulos')
  end

  def self.sanitize_value(value)
    return '' if value.nil?

    case value
    when Array
      value.join(';')
    when TrueClass
      'Sim'
    when FalseClass
      'Não'
    else
      value
    end
  end

  def self.csv_columns(max_partners)
    attributes = ['Carimbo de data/hora', 'CNPJ', 'Nome', 'Razão social da empresa',
                  'Ano de fundação', 'CNAE', 'Telefone comercial', 'Emails',
                  'Endereço', 'Bairro', 'Cidade sede', 'Estado', 'CEP', 'Breve descrição',
                  'Produtos e serviços', 'Tecnologias', '_', 'Site',
                  'A empresa está ou esteve em alguma incubadora ou Parque tecnológico',
                  'Em qual incubadora?', '_', '_', 'Redes sociais',
                  'Deseja a marca DNAUSP?', 'Email', 'Nome', '_', 'Confirmação', 'Permissão']

    attributes.concat(['Nome do sócio', 'NUSP', 'Vínculo', 'Unidade', 'Cargo', 'Email', 'Telefone',
                       'Quantos sócios a empresa possui?', '_'])
    attributes.concat(['_', 'Nome do sócio', 'NUSP', 'Vínculo', 'Unidade',
                       'Email'] * (max_partners - 1))

    attributes.concat(['Número de funcionários contratados como CLT',
                       'Número de colaboradores contratados como Pessoa Jurídica (PJ)',
                       'Número de estagiários/bolsistas contratados',
                       'A empresa recebeu investimento?', 'Investimentos',
                       'Valor do investimento próprio (R$)', 'Valor do investimento-anjo (R$)',
                       'Valor do Venture Capital (R$)', 'Valor do Private Equity (R$)',
                       'Valor do PIPE-FAPESP (R$)', 'Valor de outros investimentos (R$)',
                       'Faturamento',
                       '_', '_', '_', '_', '_', '_', '_', '_', '_', '_', '_', '_', '_', '_', '_',
                       'Objetivos de Desenvolvimento Sustentável',
                       'Data da última atualização de Colaboradores',
                       'Data da última atualização de Faturamento',
                       'Data da última atualização de Investimento'])
  end

  def self.basic_values_to_csv(company)
    result = []
    result.concat(%i[created_at cnpj name].map do |attr|
      sanitize_value(company[attr])
    end)

    attributes = ['Razão social da empresa',
                  'Ano de fundação', 'cnae', 'Telefone comercial', 'Emails',
                  'Endereço', 'Bairro', 'Cidade sede', 'Estado', 'CEP', 'Breve descrição',
                  'Produtos e serviços', 'Tecnologias', '_', 'Site',
                  'A empresa está ou esteve em alguma incubadora ou Parque tecnológico',
                  'Em qual incubadora?', '_', '_', 'Redes sociais']

    result.concat(attributes.map do |attr|
      next '' if attr.eql?('_')

      sanitize_value(company[:company_values][attr.to_sym])
    end)
  end

  def self.dna_values_to_csv(company)
    attributes = %w[wants_dna email name _]

    attributes.map do |attr|
      next '' if attr.eql?('_')

      sanitize_value(company[:dna_values][attr.to_sym])
    end
  end

  def self.verification_values_to_csv(company)
    %i[truthful_informations permission].map do |attr|
      sanitize_value(company[attr])
    end
  end

  def self.partners_values_to_csv(max_partners, company)
    partners = company[:partners_values]
    return ([''] * 6 * max_partners).concat([''] * 3) if partners.nil? || !partners.length.positive?

    result = []
    first_partner_attributes = %i[name nusp bond unity role email phone]
    partner_attributes = %i[name nusp bond unity email]

    result.concat(first_partner_attributes.map do |attr|
      sanitize_value(partners[0][attr])
    end)

    result.concat([partners.length, ''])

    (1...max_partners).each do |i|
      if i < partners.length
        partner = partners[i]
        result << ''
        result.concat(partner_attributes.map do |attr|
          sanitize_value(partner[attr])
        end)
      else
        result.concat([''] * 6)
      end
    end
    result
  end

  def self.finantial_values_to_csv(company)
    attributes = ['Número de funcionários contratados como CLT',
                  'Número de colaboradores contratados como Pessoa Jurídica (PJ)',
                  'Número de estagiários/bolsistas contratados',
                  'A empresa recebeu investimento?', 'Investimentos',
                  'Valor do investimento próprio (R$)', 'Valor do investimento-anjo (R$)',
                  'Valor do Venture Capital (R$)', 'Valor do Private Equity (R$)',
                  'Valor do PIPE-FAPESP (R$)', 'Valor de outros investimentos (R$)',
                  'Faturamento',
                  '_', '_', '_', '_', '_', '_', '_', '_', '_', '_', '_', '_', '_', '_', '_',
                  'Objetivos de Desenvolvimento Sustentável',
                  'Data da última atualização de Colaboradores',
                  'Data da última atualização de Faturamento',
                  'Data da última atualização de Investimento']

    attributes.map do |attr|
      next '' if attr.eql?('_')

      sanitize_value(company[:company_values][attr.to_sym])
    end
  end

  def self.to_csv
    max_partners = ENV['CSV_MAX_PARTNERS'] || 5
    attributes = csv_columns(max_partners)
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |company|
        row = []

        row.concat(basic_values_to_csv(company))
        row.concat(dna_values_to_csv(company))
        row.concat(verification_values_to_csv(company))
        row.concat(partners_values_to_csv(max_partners, company))
        row.concat(finantial_values_to_csv(company))

        csv << row
      end
    end
  end
end

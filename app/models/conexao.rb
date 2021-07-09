# frozen_string_literal: true

class Conexao
  include Mongoid::Document
  field :personal, type: Hash
  field :org, type: Hash
  field :demand, type: Hash

  validates :personal, :org, :demand, presence: true
  validate :validate_personal, :validate_org, :validate_demand

  def validate_personal
    attr = %i[email name represent]
    validate_fields(personal, attr)
  end

  def validate_org
    attr = %i[email name cnpj sensitiveData size phone address city]
    return unless validate_fields(org, attr)

    errors.add(:org, :invalid) unless %r{\A\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}\z}.match?(org[:cnpj])
    errors.add(:org, :invalid) unless [true, false].include?(org[:sensitiveData])
    errors.add(:org, :invalid) unless %w[Pequena Média Grande].include?(org[:size])
  end

  def validate_demand
    attr = %i[cnae description expectation wantedProfile necessity]
    return unless validate_fields(demand, attr)

    major = demand[:cnae][:major]
    errors.add(:demand, :invalid) unless cnae_majors.include?(major) &&
                                         cnae_major_to_minors[major].include?(demand[:cnae][:minor])
    errors.add(:demand, :invalid) unless knowdge_fields.include?(demand[:wantedProfile])
  end

  def validate_fields(model, fields)
    is_valid = model.is_a?(Hash)
    if is_valid
      fields.each do |field|
        is_valid = model.include?(field)
      end
    end

    errors.add(:model, :invalid) unless is_valid
    is_valid
  end

  def to_s
    header = ['Dados Pessoais:']
    header.push("\tNome: #{personal[:name]}")
    header.push("\tEmail: #{personal[:email]}")
    header.push("\tRepresenta uma: #{personal[:represent]}")
    header.push('Dados da organização:')
    header.push("\tNome: #{org[:name]}")
    header.push("\tEmail: #{org[:email]}")
    header.push("\tCNPJ: #{org[:cnpj]}")
    header.push("\tOs dados são sigilosos?: #{org[:sensitiveData]}")
    header.push("\tTamanho da empresa: #{org[:size]}")
    header.push("\tTelefone: #{org[:phone]}")
    header.push("\tEndereço: #{org[:address]}")
    header.push("\tCidade: #{org[:city]}")
    header.push('Demanda:')
    header.push("\tÁrea Primária: #{demand[:cnae][:major]}")
    header.push("\tÁrea Secundária: #{demand[:cnae][:minor]}")
    header.push("\tDescrição: #{demand[:description]}")
    header.push("\tExpectativa: #{demand[:expectation]}")
    header.push("\tPerfil de pesquisador desejado: #{demand[:wantedProfile]}")
    header.push("\tQual é a sua necessidade em relação a esses pesquisadores?: #{demand[:necessity]}")
    "#{header.join("\n")}\n\n"
  end
end

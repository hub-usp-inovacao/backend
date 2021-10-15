# frozen_string_literal: true

class CompanyUpdate
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :cnpj, type: String
  field :partners_values, type: Array
  field :company_values, type: Array
  field :delivered, type: Boolean, default: false

  validates :name, :cnpj, :partners_values, :company_values, presence: true
  validates :cnpj,
            format: { with: %r{\A\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}\z},
                      message: 'must be a valid cnpj' }
  validate :validate_partners_values, :validate_company_values

  def validate_bond(bond)
    ['Aluno ou ex-aluno de graduação',
     'Aluno ou ex-aluno de pós-graduação (mestrado ou doutorado)',
     'Aluno ou ex-aluno de pós-graduação do IPEN (Instituto de Pesquisas Energéticas e Nucleares)',
     'Docente', 'Docente aposentado / Licenciado', 'Pós-doutorando', 'Pesquisador',
     'Empresa incubada ou graduada em incubadora associada à USP'].include?(bond)
  end

  def validate_partner(partner)
    base_attr = %i[name email bond]

    partner.is_a?(Hash) && base_attr.all? do |attr|
      partner.key?(attr)
    end && validate_bond(partner[:bond])
  end

  def validate_partners_values
    return if partners_values.is_a?(Array) && partners_values.all? do |partner|
                validate_partner(partner)
              end

    errors.add(:partners_values, :invalid)
  end

  def validate_company_values
    return if company_values.is_a?(Array) && !company_values.detect { |value| !value.is_a?(Hash) }

    errors.add(:company_values, :invalid)
  end
end

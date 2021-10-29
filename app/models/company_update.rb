# frozen_string_literal: true

class CompanyUpdate
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :cnpj, type: String
  field :partners_values, type: Array
  field :company_values, type: Array
  field :delivered, type: Boolean, default: false

  validates :name, :cnpj, presence: true
  validates :cnpj,
            format: { with: %r{\A\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}\z},
                      message: 'must be a valid cnpj' }
  validate :validate_partners_values, :validate_company_values, :validate_values_presence

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

  def validate_company_values
    return unless company_values
    return if company_values.is_a?(Array) && !company_values.detect { |value| !value.is_a?(Hash) }

    errors.add(:company_values, :invalid)
  end

  def validate_values_presence
    return if company_values || partners_values

    errors.add(:company_values, 'Company_values e Partners_values não podem ser ambos nulos')
    errors.add(:partners_values, 'Company_values e Partners_values não podem ser ambos nulos')
  end
end

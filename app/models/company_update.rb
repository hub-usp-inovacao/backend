# frozen_string_literal: true

class CompanyUpdate
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :cnpj, type: String
  field :email, type: String
  field :phone, type: String
  field :name, type: String
  field :new_values, type: Array

  validates :cnpj, :name, :email, :phone, :new_values, presence: true
  validates :cnpj,
            format: { with: %r{\A\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}\z},
                      message: 'must be a valid cnpj' }
  validate :validate_new_values

  def validate_new_values
    return if new_values.is_a?(Array) && !new_values.detect { |value| !value.is_a?(Hash) }

    errors.add(:new_values, :invalid)
  end

  def to_s
    header = [
      "CNPJ: #{cnpj}",
      "Nome: #{name}",
      "Email: #{email}",
      "Telefone: #{phone}"
    ]
    items = new_values.map do |hash|
      attr = hash.keys[0]
      val = hash[attr]
      "\t- #{attr}: #{val}"
    end

    "#{(header + items).join("\n")}\n\n"
  end
end

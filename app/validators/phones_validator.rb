# frozen_string_literal: true

class PhonesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if list_of_phones? value

    error_message = 'devem ser números válidos. Ex: (16) 98209-6445'

    record.errors[attribute] << (options[:message] || error_message)
  end

  def list_of_phones?(value)
    value.is_a?(Array) &&
      value.all? do |val|
        phone_valid? val
      end
  end

  def phone_valid?(phone)
    raw = phone.gsub(/\D/, '')
    raw.match?(/^\d{8,13}$/)
  end
end

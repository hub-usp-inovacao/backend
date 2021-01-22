# frozen_string_literal: true

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if url_valid?(value)

    record.errors[attribute] << (options[:message] || 'must be a valid URL')
  end

  def url_valid?(url)
    url = begin
      URI.parse(url)
    rescue StandardError
      false
    end
    url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS)
  end
end

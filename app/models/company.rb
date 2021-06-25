# frozen_string_literal: true

class Company
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :year, type: String
  field :services, type: String
  field :url, type: String
  field :logo, type: String

  field :incubated, type: Boolean
  field :allowed, type: Boolean
  field :active, type: Boolean

  field :emails, type: Array
  field :ecosystems, type: Array
  field :technologies, type: Array
  field :phones, type: Array
  field :companySize, type: Array

  field :description, type: Hash
  field :classification, type: Hash
  field :address, type: Hash

  validates :name, :year, :emails, :description, :incubated, :ecosystems, :services, :address,
            :classification,
            presence: true
  validates :name, length: { in: 2..100 }
  validates :url, :logo, url: true

  validate :valid_year?, :valid_company_size?, :valid_classification?

  def valid_year?
    return if year.nil?

    is_valid = year.is_a?(String) &&
               year.match?(/^\d{4}$/) &&
               year.to_i <= Time.zone.now.year
    errors.add(:year, 'must be a string representing a non-future year') unless is_valid
  end

  def valid_company_size?
    is_valid = !companySize.nil? &&
               companySize.is_a?(Array) &&
               companySize.all? { |size| company_sizes.include?(size) }
    errors.add(:companySize, "must be one of #{company_sizes}") unless is_valid
  end

  def valid_classification?
    c = classification

    is_valid = c.is_a?(Hash) &&
               c.key?(:major) &&
               c.key?(:minor) &&
               cnae_majors.include?(c[:major]) &&
               cnae_major_to_minors[c[:major]].include?(c[:minor])

    errors.add(:classification, 'invalid major and/or minor') unless is_valid
  end
end

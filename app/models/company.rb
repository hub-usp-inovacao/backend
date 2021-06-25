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
    return if year.nil? || year == 'N/D'

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
    return if classification.nil?

    c = classification

    is_valid = c.is_a?(Hash) &&
               c.key?(:major) &&
               c.key?(:minor) &&
               cnae_majors.include?(c[:major]) &&
               cnae_major_to_minors[c[:major]].include?(c[:minor])

    errors.add(:classification, 'invalid major and/or minor') unless is_valid
  end

  def self.create_from(row)
    new_company = Company.new(
      {
        name: row[2],
        year: row[4],
        emails: row[7].split(';'),
        description: { long: row[13] },
        incubated: incubated?(row),
        ecosystems: row[19].split(';'),
        services: row[14],
        address: define_address(row),
        phones: row[6].split(';'),
        url: format_url(row[17]),
        technologies: row[15].split(';'),
        logo: create_image_url(row[16]),
        classification: classify(row),
        companySize: ['Microempresa']
      }
    )

    raise StandardError, new_company.errors.full_messages unless new_company.save

    new_company
  end

  def self.create_image_url(raw)
    "https://drive.google.com/uc?export=view&id=#{raw}"
  end

  def self.format_url(raw)
    return nil if raw.size.zero?

    return "https://#{raw}" if raw[0..3] != 'http'

    raw
  end

  def self.incubated?(row)
    yesses = ['Sim. A empresa está incubada.', 'Sim. A empresa já está graduada']
    yesses.include? row[18]
  end

  def self.define_address(row)
    {
      venue: row[8],
      neightborhood: row[9],
      city: row[10].split(';'),
      state: row[11],
      cep: row[12]
    }
  end

  def self.classify(row)
    default = { major: '', minor: '' }

    return default if row.nil? || row[5].size.zero?

    code = row[5][0..1]
    major_minor = cnae_code_to_major_minor[code]

    return default unless code && major_minor

    {
      major: major_minor[:major],
      minor: major_minor[:minor]
    }
  end
end

# frozen_string_literal: true

class Company
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :cnpj, type: String
  field :name, type: String
  field :year, type: String
  field :url, type: String
  field :logo, type: String
  field :corporate_name, type: String
  field :cnae, type: String
  field :incubated, type: String

  field :allowed, type: Boolean
  field :active, type: Boolean

  field :emails, type: Array
  field :ecosystems, type: Array
  field :technologies, type: Array
  field :phones, type: Array
  field :companySize, type: Array
  field :partners, type: Array
  field :services, type: Array

  field :description, type: Hash
  field :classification, type: Hash
  field :address, type: Hash

  field :collaborators_last_updated_at, type: DateTime
  field :investments_last_updated_at, type: DateTime
  field :revenues_last_updated_at, type: DateTime

  validates :cnpj,
            :name,
            :year,
            :description,
            :incubated,
            :ecosystems,
            :services,
            :address,
            :classification,
            :corporate_name,
            presence: true

  validates :corporate_name,
            uniqueness: { message: 'já cadastrado (Duplicado)' }
  validates :url, :logo, url: true
  validates :phones, phones: true

  validate :valid_cnpj?, :valid_year?, :valid_classification?, :valid_address?

  def valid_cnpj?
    is_valid = !cnpj.nil? &&
               cnpj =~ %r{\A(\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}|Exterior\d*)\Z}

    errors.add(:cnpj, 'mal formatado. Exemplo: dd.ddd.ddd/dddd-dd ou Exterior12') unless is_valid
  end

  def valid_address?
    is_valid = !address.nil? &&
               address.is_a?(Hash) &&
               address.key?(:city)

    errors.add(:address, 'deve possuir no mínimo a cidade') unless is_valid
  end

  def valid_year?
    return if year.nil? || year == 'N/D'

    is_valid = year.is_a?(String) &&
               year.match?(/^\d{4}$/) &&
               year.to_i <= Time.zone.now.year
    errors.add(:year, 'não deve ser um ano futuro') unless is_valid
  end

  def valid_classification?
    c = classification
    is_valid = cnae_majors.include?(c[:major]) &&
               cnae_major_to_minors[c[:major]].include?(c[:minor])

    errors.add(:classification, 'inválida devido a inválido cnae') unless is_valid
  end

  def self.create_from(row)
    classification = classify(row[5])

    new_company = Company.new(
      {
        cnpj: row[1],
        name: row[2],
        year: row[4],
        emails: row[7]&.split(';'),
        description: { long: row[13] },
        incubated: incubated?(row[18]),
        ecosystems: row[19]&.split(';'),
        services: row[14]&.split(';'),
        address: define_address(row),
        phones: format_phone(row[6]),
        url: format_url(row[17]),
        technologies: row[15]&.split(';'),
        logo: create_image_url(row[16]),
        classification: classification,
        cnae: row[5],
        companySize: size(row[21], row[20], classification),
        partners: partners(row),
        corporate_name: row[3],
        collaborators_last_updated_at: timestamp(row[85]),
        investments_last_updated_at: timestamp(row[87]),
        revenues_last_updated_at: timestamp(row[86])
      }
    )

    raise StandardError, new_company.errors.full_messages unless new_company.save

    new_company
  end

  def self.timestamp(raw)
    return 'N/D' if raw.nil? || raw.size.eql?(0)

    d, m, y = raw.split('/').map(&:to_i)
    DateTime.new y, m, d
  end

  def self.partner(subrow)
    {
      name: subrow[0],
      nusp: subrow[1],
      bond: subrow[2],
      unity: subrow[3],
      email: subrow[5] || '',
      phone: subrow[6] || ''
    }
  end

  def self.partners(row)
    parsed_partners = []

    subrows_indices = [29..35, 39..42, 44..47, 49..52, 54..57]
    subrows_indices.each do |subrow_indices|
      return parsed_partners if row[subrow_indices].nil?

      not_empty = row[subrow_indices].any? { |entry| entry.size.positive? }
      parsed_partners << partner(row[subrow_indices]) if not_empty
    end

    parsed_partners
  end

  def self.size(employees, unicorn, classification)
    sizes = unicorn == 'Unicórnio' ? [unicorn] : []

    employees = employees.to_i

    return sizes.append('Não Informado') unless employees.positive?

    if classification[:major] == 'Indústria de Transformação'
      case employees
      when 1...20
        sizes.append 'Microempresa'
      when 20...100
        sizes.append 'Pequena Empresa'
      when 100...500
        sizes.append 'Média Empresa'
      else
        sizes.append 'Grande Empresa'
      end
    else
      case employees
      when 1...10
        sizes.append 'Microempresa'
      when 10...50
        sizes.append 'Pequena Empresa'
      when 50...100
        sizes.append 'Média Empresa'
      else sizes.append 'Grande Empresa'
      end
    end

    sizes
  end

  def self.format_phone(raw)
    return [] if raw.nil? || raw == 'N/D'

    raw.split(';').map do |phone|
      numbers = phone.gsub(/\D/, '')
      case numbers.size
      when 13
        # +55 (11) 98765 - 4321
        "+#{numbers[0..1]} (#{numbers[2..3]}) #{numbers[4..8]} - #{numbers[9..]}"
      when 12
        # +55 (11) 8765 - 4321
        "+#{numbers[0..1]} (#{numbers[2..3]}) #{numbers[4..7]} - #{numbers[8..]}"
      when 11
        # (11) 98765 - 4321
        "(#{numbers[0..1]}) #{numbers[2..6]} - #{numbers[7..]}"
      when 10
        # (11) 8765 - 4321
        "(#{numbers[0..1]}) #{numbers[2..5]} - #{numbers[6..]}"
      when 9
        # 98765 - 4321
        "#{numbers[0..4]} - #{numbers[5..]}"
      when 8
        # 8765 - 4321
        "#{numbers[0..3]} - #{numbers[4..]}"
      else
        # no particular format
        numbers
      end
    end
  end

  def self.create_image_url(raw)
    return nil if raw.nil? || raw == 'N/D'

    "https://drive.google.com/uc?export=view&id=#{raw}"
  end

  def self.format_url(raw)
    return nil if raw.nil? || raw == 'N/D'

    return "https://#{raw}" if raw[0..3] != 'http'

    raw
  end

  def self.incubated?(incubated)
    return 'Não' unless /\ASim.+\Z/.match?(incubated)

    incubated
  end

  def self.define_address(row)
    {
      venue: row[8],
      neighborhood: row[9],
      city: row[10]&.split(';'),
      state: row[11],
      cep: row[12]
    }
  end

  def self.classify(cnae)
    default = { major: '', minor: '' }

    return default if cnae.nil?

    matches = cnae.match(/(\d+)\.+/)
    code = matches && matches.captures[0]

    return default if code.nil? || code.length > 2

    major_minor = cnae_code_to_major_minor[code]

    return default unless code && major_minor

    {
      major: major_minor[:major],
      minor: major_minor[:minor]
    }
  end
end

# frozen_string_literal: true

class Discipline
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :campus, type: String
  field :unity, type: String
  field :start_date, type: String
  field :nature, type: String
  field :level, type: String
  field :url, type: String
  field :description, type: Hash
  field :category, type: Hash
  field :keywords, type: Array
  field :offeringPeriod, type: String

  validates :name, :campus, :unity, :description, :category, :nature, :level, presence: true
  validates :name,
            format: { with: /\A(\w|\d){3}\d{4} (-|–) .+\z/,
                      message: 'deve ser um nome válido. Ex: ACH2501' }
  validates :url, url: true
  validate :a_valid_level?, :a_valid_nature?, :a_valid_campi?, :a_valid_unity?, :a_valid_category?

  def a_valid_level?
    valid_levels = entrepreneurship_levels
    errors.add(:level, 'deve ser um nível válido') unless valid_levels.include?(level)
  end

  def a_valid_nature?
    valid_natures = %w[graduação pós-graduação]

    is_valid = !nature.nil? &&
               valid_natures.include?(nature.downcase)

    errors.add(:nature, 'deve ser uma natureza válida (Graduação ou Pós-Graduação)') unless is_valid
  end

  def a_valid_campi?
    valid_campi = campi.map { |c| c[:name] }
    errors.add(:campus, 'deve ser um campus válido') unless valid_campi.include?(campus)
  end

  def a_valid_unity?
    valid_unities = campi.reduce([]) do |acc, c|
      acc.concat(c[:unities])
    end
    errors.add(:unity, 'deve ser uma unidade válida') unless valid_unities.include?(unity)
  end

  def a_valid_category?
    is_valid = !category.nil? &&
               category.any? { |_key, value| value == true }

    errors.add(:category, 'deve possuir pelo menos um tipo de categoria') unless is_valid
  end

  def self.create_from(row)
    new_discipline = Discipline.new(
      {
        name: row[1],
        campus: row[2],
        unity: row[3],
        start_date: row[8],
        nature: row[0],
        level: row[5],
        url: row[4],
        description: {
          short: '',
          long: row[6]
        },
        offeringPeriod: row[13],
        category: create_category(row),
        keywords: create_keywords(row)
      }
    )

    raise StandardError, new_discipline.errors.full_messages unless new_discipline.save

    new_discipline
  end

  def self.create_keywords(row)
    kws = []

    kws << 'Negócios' if row[9]
    kws << 'Empreendedorismo' if row[10]
    kws << 'Inovação' if row[11]
    kws << 'Propriedade Intelectual' if row[12]

    kws
  end

  def self.create_category(row)
    {
      business: row[9]&.casecmp('x')&.zero?,
      entrepreneurship: row[10]&.casecmp('x')&.zero?,
      innovation: row[11]&.casecmp('x')&.zero?,
      intellectual_property: row[12]&.casecmp('x')&.zero?
    }
  end
end

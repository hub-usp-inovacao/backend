# frozen_string_literal: true

class Discipline
  include Mongoid::Document

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

  validates :name, :campus, :unity, :description, :category, :nature, :level, presence: true
  validates :name, format: { with: /\A(\w|\d){3}\d{4} (-|–) .+\z/, message: 'must be a valid name' }
  validates :url, url: true
  validate :a_valid_level?, :a_valid_nature?, :a_valid_campi?, :a_valid_unity?, :a_valid_category?

  def a_valid_level?
    valid_levels = entrepreneurship_levels
    errors.add(:level, 'must be a valid level') unless valid_levels.include?(level)
  end

  def a_valid_nature?
    valid_natures = %w[graduação pós-graduação]
    errors.add(:nature, 'must be a valid nature') unless valid_natures.include?(nature.downcase)
  end

  def a_valid_campi?
    valid_campi = campi.map { |c| c[:name] }
    errors.add(:campus, 'must be a valid campi') unless valid_campi.include?(campus)
  end

  def a_valid_unity?
    valid_unities = campi.reduce([]) do |acc, c|
      acc.concat(c[:unities])
    end
    errors.add(:unity, 'must be a valid campi') unless valid_unities.include?(unity)
  end

  def a_valid_category?
    return if category.any? { |_key, value| value == true }

    errors.add(:category, 'at least one category must be true')
  end

  def self.create_from(row)
    kws = []

    kws << 'Negócios' if row[10]
    kws << 'Propriedade Intelectual' if row[13]
    kws << 'Inovação' if row[12]
    kws << 'Empreendedorismo' if row[11]
    abuble = Discipline.create!(
      name: row[1],
      campus: row[2],
      unity: row[3],
      start_date: row[8],
      nature: row[0],
      level: row[5],
      url: row[4],
      description: {
        short: row[6],
        long: row[7]
      },
      category: {
        business: row[10].size.positive?,
        entrepreneurship: row[11].size.positive?,
        innovation: row[12].size.positive?,
        intellectual_property: row[13].size.positive?
      },
      keywords: kws
    )
  end
end

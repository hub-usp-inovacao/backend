# frozen_string_literal: true

require Rails.root.join('data/entrepreneurship_levels')
require Rails.root.join('data/campi')

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
  validates :name, format: { with: /\A(\w|\d){3}\d{4} (-|–) .+\z/, message: '' }
  validates :url, url: true
  validate :a_valid_level?, :a_valid_nature?, :a_valid_campi?, :a_valid_unity?, :a_valid_category?

  def a_valid_level?
    valid_levels = EntrepreneurshipLevels.new.call
    errors.add(:level, 'must be a valid level') unless valid_levels.include?(level)
  end

  def a_valid_nature?
    valid_natures = %w[graduação pós-graduação]
    errors.add(:nature, 'must be a valid nature') unless valid_natures.include?(nature.downcase)
  end

  def a_valid_campi?
    valid_campi = Campi.new.call.map { |c| c[:name] }
    errors.add(:campus, 'must be a valid campi') unless valid_campi.include?(campus)
  end

  def a_valid_unity?
    valid_unities = Campi.new.call.reduce([]) do |acc, c|
      acc.concat(c[:unities])
    end
    errors.add(:campus, 'must be a valid campi') unless valid_unities.include?(unity)
  end

  def a_valid_category?
    unless category.any? { |_key, value| value == true }
      errors.add(:category, 'at least one category must be true')
    end
  end
end

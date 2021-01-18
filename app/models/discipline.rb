# frozen_string_literal: true

require "#{Rails.root}/data/entrepreneurship_levels"

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
  validate :a_valid_level?
  # nature: duas opções (graduação and pós-graduação)
  # campus and unity: tem uma lista definida
  # url: formatar com regex
  # category: tem que ser um hash com 4 chaves específicas, sendo pelo menos
  #           uma delas 'true' (business, entrepreneurship, innovation, intellectual_property)

  def a_valid_level?
    valid_levels = EntrepreneurshipLevels.new.call
    errors.add(:level, 'must be a valid level') unless valid_levels.include?(level)
  end
end

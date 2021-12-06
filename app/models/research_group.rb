# frozen_string_literal: true

class ResearchGroup
  include Mongoid::Document

  field :bond, type: String
  field :categories, type: Array
  field :name, type: String
  field :initials, type: String
  field :site, type: String

  embedded_in :skill, inverse_of: :research_groups

  validates :bond, :name, :categories, presence: true
  validates :site, url: true

  def self.get_categories(raw)
    return nil unless raw.respond_to?(:split)

    raw.split(';')
  end

  def self.get_url(raw)
    return nil if raw.eql?('N/D')

    return raw if raw[0...4].eql? 'http'

    "http://#{raw}"
  end

  def self.new_from(row)
    return nil if row.eql?(['N/D'] * 5)

    group = ResearchGroup.new(
      {
        bond: row[0],
        categories: get_categories(row[1]),
        name: row[2],
        initials: row[3],
        site: get_url(row[4])
      }
    )

    unless group.valid?
      errors = group.errors.full_messages.map do |msg|
        "[Grupo ou Laboratório de Pesquisa] - #{msg}"
      end
      raise StandardError, errors.to_a
    end

    group
  end

  def self.new_first_from(row)
    new_from row[8..12]
  end

  def self.new_second_from(row)
    new_from row[13..17]
  end

  def self.new_third_from(row)
    new_from row[18..22]
  end
end

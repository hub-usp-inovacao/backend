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
    raw.eql?('N/D') ? nil : raw
  end

  def self.create_from(row)
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

    raise StandardError unless group.valid?

    group
  end

  def self.create_first_from(row)
    create_from row[8..12]
  end

  def self.create_second_from(row)
    create_from row[13..17]
  end

  def self.create_third_from(row)
    create_from row[18..22]
  end
end

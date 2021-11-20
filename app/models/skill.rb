# frozen_string_literal: true

class Skill
  include Mongoid::Document

  field :name, type: String
  field :email, type: String
  field :unities, type: Array
  field :keywords, type: Array
  field :lattes, type: String
  field :photo, type: String
  field :skills, type: Array
  field :services, type: Array
  field :equipments, type: Array

  embeds_many :research_groups

  validates :name, :email, :lattes, presence: true
  validates :lattes, :photo, url: true
  validate :valid_unities?, :valid_keywords?

  def valid_unities?
    is_valid = !unities.nil? &&
               unities.is_a?(Array) &&
               unities.all? { |un| all_unities.include? un }

    errors.add(:unities, :invalid) unless is_valid
  end

  def valid_keywords?
    is_valid = !keywords.nil? &&
               keywords.is_a?(Array) &&
               keywords.all? { |kw| kw.is_a?(String) && kw.size.positive? }

    errors.add(:keywords, :invalid) unless is_valid
  end

  def self.create_from(row)
    skill = new(
      {
        name: row[2],
        email: row[3],
        unities: unities(row[5]),
        keywords: kws(row[28]),
        lattes: row[29],
        photo: photo_url(row[30]),
        skills: get_skills(row[23]),
        services: get_services(row[24]),
        equipments: get_equipments(row[25])
      }
    )

    gr1 = ResearchGroup.create_first_from row
    skill.research_groups << gr1 unless gr1.nil?

    gr2 = ResearchGroup.create_second_from row
    skill.research_groups << gr2 unless gr2.nil?

    gr3 = ResearchGroup.create_third_from row
    skill.research_groups << gr3 unless gr3.nil?

    raise StandardError, skill.errors.full_messages unless skill.save

    skill
  end

  def self.get_skills(raw)
    return [] if raw.eql? 'N/D'

    raw.split(';')
  end

  def self.get_services(raw)
    return [] if raw.eql? 'N/D'

    raw.split(';')
  end

  def self.get_equipments(raw)
    return [] if raw.eql? 'N/D'

    raw.split(';')
  end

  def self.photo_url(id)
    return nil if id.elq?('N/D')

    "https://drive.google.com/uc?export=view&id=#{id}"
  end

  def self.kws(raw)
    raw.split(';')
  end

  def self.unities(raw)
    raw.split(';').select { |unity| unity.size.positive? }
  end
end

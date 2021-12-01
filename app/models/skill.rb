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
  field :phones, type: Array
  field :limit_date, type: DateTime
  field :bond, type: String
  field :campus, type: String
  field :area, type: Hash

  embeds_many :research_groups

  validates :name, :email, :lattes, presence: true
  validates :name, uniqueness: true
  validates :lattes, :photo, url: true
  validates :phones, phones: true
  validate :valid_unities?, :valid_keywords?, :valid_bond?, :valid_limit_date?

  def valid_limit_date?
    is_valid = limit_date.nil? || limit_date.is_a?(Date)

    errors.add(:limit_date, :invalid) unless is_valid
  end

  def valid_bond?
    valids = [
      'Aluno de Doutorado',
      'Docente',
      'Docente Sênior',
      'Funcionário',
      'PART (Programa de Atração e Retenção de Talentos)',
      'Pesquisador (Pós-doutorando)',
      'Professor Contratado'
    ]

    is_valid = !bond.nil? &&
               bond.is_a?(String) &&
               valids.include?(bond)

    errors.add(:bond, :invalid) unless is_valid
  end

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

  # rubocop:disable Metrics/AbcSize
  def self.create_from(row)
    unis = get_unities(row[5])
    skill = new(
      {
        name: row[2],
        email: row[3],
        unities: unis,
        keywords: kws(row[28]),
        lattes: row[29],
        photo: photo_url(row[30]),
        skills: split_unless_nd(row[23]),
        services: split_unless_nd(row[24]),
        equipments: split_unless_nd(row[25]),
        phones: split_unless_nd(row[31]),
        limit_date: row[36],
        bond: row[1],
        campus: get_campus(row[6], unis),
        area: get_area(row[26], row[27])
      }
    )

    gr1 = ResearchGroup.new_first_from row
    skill.research_groups.push(gr1) unless gr1.nil?

    gr2 = ResearchGroup.new_second_from row
    skill.research_groups.push(gr2) unless gr2.nil?

    gr3 = ResearchGroup.new_third_from row
    skill.research_groups.push(gr3) unless gr3.nil?

    raise StandardError, skill.errors.full_messages unless skill.save

    skill
  end
  # rubocop:enable Metrics/AbcSize

  def self.get_area(raw_major, raw_minor)
    raw_majors = raw_major.split(';')
    minors = raw_minor.split(';')

    if raw_majors.empty?
      {
        minor: minors,
        major: minors.map { |minor| infer_major(minor) }
      }
    else
      {
        minor: minors,
        major: raw_majors
      }
    end
  end

  def self.infer_major(minor)
    area = knowledge_areas.detect do |ka|
      ka[:subareas].include? minor
    end

    area.nil? ? nil : area[:name]
  end

  def self.get_campus(raw, unis)
    if raw.nil? || raw.eql?('')
      infer_campus(unis[0])
    else
      raw
    end
  end

  def self.infer_campus(unity)
    campus_entry = campi.detect do |entry|
      entry[:unities].include? unity
    end

    campus_entry.nil? ? nil : campus_entry[:name]
  end

  def self.split_unless_nd(raw)
    return [] if raw.eql? 'N/D'

    raw.split(';')
  end

  def self.photo_url(id)
    return nil if id.eql?('N/D')

    "https://drive.google.com/uc?export=view&id=#{id}"
  end

  def self.kws(raw)
    raw.split(';')
  end

  def self.get_unities(raw)
    raw.split(';')
  end
end

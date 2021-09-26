# frozen_string_literal: true

class Skill
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :email, type: String
  field :unities, type: Array
  field :campus, type: String
  field :labs_or_groups, type: Array
  field :description, type: Hash
  field :area, type: Hash
  field :phone, type: String
  field :keywords, type: Array
  field :lattes, type: String
  field :picture, type: String
  field :limit_date, type: String
  field :bond, type: String

  validates :name, :email, :unities, :campus, presence: true
  validates :lattes, :picture, url: true

  validate :a_valid_campi?, :a_valid_area?

  def a_valid_area?
    is_valid = !area.nil? &&
               area.keys.sort.eql?(%w[major minor]) &&
               knowledge_areas.any? do |karea|
                 karea[:name].eql?(area[:major]) && karea[:subareas].include?(area[:minor])
               end

    errors.add(:area, 'invalid area') unless is_valid
  end

  def a_valid_campi?
    is_valid = !campus.nil? &&
               campi.any? do |valid_campus|
                 valid_campus[:name].eql?(campus)
               end

    errors.add(:campus, 'invalid campus') unless is_valid
  end

  def self.create_from(row)
    new_skill = Skill.new({
                            name: row[2],
                            email: row[3],
                            unities: row[5],
                            campus: row[6],
                            phone: format_phone(row),
                            description: {
                              skills: row[23],
                              services: row[24],
                              equipments: row[25]
                            },
                            area: {
                              major: row[26],
                              minor: row[27]
                            },
                            keywords: row[28].split(';'),
                            labs_or_groups: labs_or_groups_from(row)
                          })

    raise StandardError, new_skill.errors.full_messages unless new_skill.save

    new_skill
  end

  def label_lab_or_group(name, initials, bond)
    label = name

    no_initials = initials.nil? || initials.eql?('N/D')
    no_bond = bond.nil? || bond.eql?('N/D')

    label = "#{label} (#{initials})" unless no_initials
    label = "#{label} - #{bond}" unless no_bond

    label
  end

  def self.format_lab_or_group(row)
    {
      name: row[2],
      label: label_lab_or_group(row[2], row[3], row[0]),
      site: row[4]
    }
  end

  def self.labs_or_groups_from(row)
    first = format_lab_or_group(row[8..12])
    second = format_lab_or_group(row[13..17])
    third = format_lab_or_group(row[18..22])

    [] << first << second << third
  end

  # TODO: extract into validator
  def self.format_phone(row)
    row.split(';').map do |phone|
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
end

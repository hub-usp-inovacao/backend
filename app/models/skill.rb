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

  def self.create_from(row)
    new_skill = Skill.new({
                            name: row[2],
                            email: row[3],
                            unities: row[5],
                            campus: row[6],
                            phone: format_phone(row)
                            # TODO: add the rest of attrs
                          })

    raise StandardError, new_skill.errors.full_messages unless new_skill.save

    new_skill
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

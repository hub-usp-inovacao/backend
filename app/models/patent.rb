# frozen_string_literal: true

class Patent
  include Mongoid::Document

  field :classification, type: Hash
  field :ipcs, type: Array
  field :owners, type: Array
  field :inventors, type: Array
  field :countries_with_protection, type: Array
  field :name, type: String
  field :status, type: String
  field :sumary, type: String
  field :url, type: String
  field :photo, type: String

  validates :name, :classification, :ipcs, :owners, :status, presence: true
  validate :valid_classification?, :valid_status?

  def valid_status?
    is_valid = ['Concedida', 'Em análise', 'Domínio Público'].include?(status)

    errors.add(:status, 'invalid status') unless is_valid
  end

  def valid_classification?
    is_valid = !classification.nil? &&
               classification.is_a?(Hash) &&
               classification.keys.sort.eql?(%i[primary secondary]) &&
               classification[:primary].keys.sort.eql?(%i[cip subarea]) &&
               classification[:secondary].keys.sort.eql?(%i[cip subarea])

    errors.add(:classification, 'invalid classification') unless is_valid
  end

  def self.create_from(row)
    new_patent = Patent.new(
      {
        name: row[5],
        sumary: row[10],
        classification: classify(row),
        ipcs: row[6].split(' | '),
        owners: row[8].split(' | '),
        status: row[12],
        url: row[14],
        inventors: row[9].split(' | '),
        countries_with_protection: row[11].split(' | '),
        photo: row[15]
      }
    )

    raise StandardError, new_patent.errors.full_messages unless new_patent.save

    new_patent
  end

  def self.classify(row)
    {
      primary: {
        cip: row[0],
        subarea: row[1]
      },
      secondary: {
        cip: row[2],
        subarea: row[3]
      }
    }
  end
end

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

  def _cip_and_subarea?(hash)
    hash.keys.sort.eql?(%i[cip subarea])
  end

  def _cip_well_formatted(cip)
    cip =~ /^[A-H] - .+$/
  end

  def _subarea_well_formatted(subarea)
    subarea =~ /^[A-H][0-9]{2} - .+$/
  end

  def cip_and_subarea?(hash)
    _cip_and_subarea?(hash) &&
      _cip_well_formatted(hash[:cip]) &&
      _subarea_well_formatted(hash[:subarea])
  end

  def valid_classification?
    clsf = classification
    is_valid = !clsf.nil? &&
               clsf.is_a?(Hash) &&
               clsf.key?(:primary) &&
               cip_and_subarea?(clsf[:primary])

    if is_valid && clsf.key?(:secondary)
      secondary_reqs = cip_and_subarea?(clsf[:secondary])
      is_valid &&= secondary_reqs
    end

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
    clsf = {
      primary: {
        cip: row[0],
        subarea: row[1]
      },
      secondary: {
        cip: row[2],
        subarea: row[3]
      }
    }

    clsf.delete(:secondary) if row[2].eql?('N/D')

    clsf
  end
end

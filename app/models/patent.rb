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
  field :summary, type: String
  field :url, type: String
  field :photo, type: String

  validates :name, :classification, :ipcs, :owners, :status, presence: true
  validates :url, :photo, url: true
  validate :valid_classification?, :valid_status?, :valid_ipcs?

  def valid_status?
    is_valid = ['Concedida', 'Em análise', 'Domínio Público'].include?(status)

    error_message = 'inválido. Possíveis status: Concedida, Em análise, Domínio Público'
    errors.add(:status, error_message) unless is_valid
  end

  def cip_well_formatted(cip)
    return true if /^[A-H] - .+$/.match?(cip)

    errors.add(:classification, 'possui CIP mal formatado. Exemplo: G - Física')
  end

  def subarea_well_formatted(subarea)
    return true if /^[A-H][0-9]{2} - .+$/.match?(subarea)

    errors.add(:classification, 'possui sub-áreas mal formatadas. Exemplo: G01 - Medição')
  end

  def valid_cip_and_subarea?(hash)
    is_valid = hash.keys.sort.eql?(%i[cip subarea])
    if is_valid
      cip_well_formatted(hash[:cip])
      subarea_well_formatted(hash[:subarea])
    else
      errors.add(:classification, 'está mal formatada')
    end
  end

  def valid_classification?
    clsf = classification
    is_valid = !clsf.nil? &&
               clsf.is_a?(Hash) &&
               clsf.key?(:primary)

    errors.add(:classification, 'está mal formatada') unless is_valid

    valid_cip_and_subarea?(clsf[:primary]) if is_valid

    valid_cip_and_subarea?(clsf[:secondary]) if is_valid && clsf.key?(:secondary)
  end

  def valid_ipcs?
    is_valid = !ipcs.nil? &&
               ipcs.all? do |ipc|
                 ipc =~ /^[A-H][0-9]{2}[A-Z][0-9]{6,}$/
               end

    errors.add(:ipcs, 'inválido. Exemplo: G01N002706') unless is_valid
  end

  def self.create_from(row)
    new_patent = Patent.new(
      {
        name: row[5],
        summary: row[10],
        classification: classify(row),
        ipcs: row[6].split(' | '),
        owners: row[8].split(' | '),
        status: row[12],
        url: create_url(row[14]),
        inventors: row[9].split(' | '),
        countries_with_protection: row[11].split(' | '),
        photo: create_image_url(row[15])
      }
    )

    raise StandardError, new_patent.errors.full_messages unless new_patent.save

    new_patent
  end

  def self.create_image_url(id)
    return nil if id == 'N/D'

    "https://drive.google.com/uc?export=view&id=#{id}"
  end

  def self.create_url(raw)
    return nil if raw == 'N/D'

    raw
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

    clsf.delete(:secondary) if row[2].eql?('N/D') || row[3].eql?('N/D')

    clsf
  end
end

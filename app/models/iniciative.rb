# frozen_string_literal: true

class Iniciative
  include Mongoid::Document

  field :name, type: String
  field :classification, type: String
  field :localization, type: String
  field :unity, type: String
  field :tags, type: Array
  field :url, type: String
  field :description, type: String
  field :email, type: String
  field :contact, type: Hash

  validates :name, :classification, :localization, presence: true
  validates :url, url: true

  validate :valid_classification?, :valid_localization?, :valid_unity?, :valid_description?,
           :valid_contact?

  def valid_contact?
    is_valid = contact.nil? ||
               contact.is_a?(Hash) &&
               %i[person info].all? do |key|
                 contact.key? key
               end

    errors.add(:contact) unless is_valid
  end

  def valid_description?
    is_valid = !description.nil? &&
               description.is_a?(String)

    errors.add(:description) unless is_valid
  end

  def valid_unity?
    is_valid = unity.eql?('N/D') || all_unities.include?(unity)

    errors.add(:unity) unless is_valid
  end

  def valid_localization?
    is_valid = campi_names.include? localization

    errors.add(:localization) unless is_valid
  end

  def valid_classification?
    classes = [
      'Agente Institucional',
      'Empresa Jr.',
      'Entidade Associada',
      'Entidade Estudantil',
      'Espaço/Coworking',
      'Grupos e Iniciativas Estudantis',
      'Ideação',
      'Incubadora e Parque Tecnológico'
    ]

    is_valid = classes.include? classification

    errors.add(:classification) unless is_valid
  end

  def self.create_from(row)
    iniciative = new({
                       classification: row[0],
                       name: row[1],
                       # row[2]
                       localization: row[3],
                       unity: row[4],
                       tags: get_tags(row[5]),
                       url: row[6],
                       description: row[7],
                       email: possible_nd(row[8]),
                       # row[9]
                       # row[10]
                       contact: get_contact(row[11], row[12])
                     })

    raise StandardError, iniciative.errors.full_messages unless iniciative.valid?

    iniciative.save

    iniciative
  end

  def self.get_contact(person, info)
    { person: person, info: info }
  end

  def self.possible_nd(raw)
    raw.eql?('N/D') ? nil : raw
  end

  def self.get_tags(raw)
    is_empty = raw.nil? || raw.size.eql?(0)

    return [] if is_empty

    raw.split ';'
  end
end

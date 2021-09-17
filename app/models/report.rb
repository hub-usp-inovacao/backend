# frozen_string_literal: true

class Report
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :entity, type: String
  field :sheet_id, type: String
  field :warnings, type: Array
  field :delivered, type: Boolean, default: true

  validates :entity, :sheet_id, :warnings, presence: true
end

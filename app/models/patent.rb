# frozen_string_literal: true

class Patent
  include Mongoid::Document

  field :name, type: String
  field :classification, type: Hash
  field :ipcs, type: Array
  field :owners, type: Array
  field :inventors, type: Array
  field :countries_with_protection, type: Array
  field :status, type: String
  field :sumary, type: String
  field :url, type: String
  field :photo, type: String
end

class Discipline
  include Mongoid::Document

  field :name, type: String
  field :campus, type: String
  field :unity, type: String
  field :start_date, type: String
  field :nature, type: String
  field :level, type: String
  field :url, type: String
  field :description, type: Hash
  field :category, type: Hash
  field :keywords, type: Array

  validates_presence_of :name, :campus, :unity, :description, :category, :nature, :level
  validates :name, format: { with: /\A(\w|\d){3}\d{4} (-|–) .+\z/, message: '' }

  # nature: duas opções (graduação and pós-graduação)
  # campus and unity: tem uma lista definida 
  # level: tem uma lista definida (roadmap de empreendedorismo) 
  # url: formatar com regex
  # category: tem que ser um hash com 4 chaves específicas, sendo pelo menos 
  #           uma delas 'true' (business, entrepreneurship, innovation, intellectual_property)
end

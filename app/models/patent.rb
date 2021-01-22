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

  # Nome: Não pode ser vazio

  # Classificação:
  # CIP: "W - NOME"
  # Sub-Área: "W__ - NOME"
  # Primário obrigatória, segundário opcional

  # IPCS: "X__Y______" EX: "G01R002722"

  # Owners, Iventors: Não pode ser vazio

  # Status: Lista definida(Concedida, Domínio Público e Em análise)

  # url: Checar se é um link

  # photo: ID Flyer
end

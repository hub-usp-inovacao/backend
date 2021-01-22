# frozen_string_literal: true

require 'rest-client'
require 'json'

class GetDisciplinesService
  def self.run
    request && parse && detect_warnings
  end

  # Fazer a requisição para o google sheets
  def self.request
    sheets_api_key = Rails.application.credentials.google_sheets_API_key
    sheet_id = '1AsmtnS5kY1mhXhNJH5QsCyg_WDnkGtARYB4nMdhyFLs'
    sheet_name = 'DISCIPLINAS'
    url =
      "https://sheets.googleapis.com/v4/spreadsheets/#{sheet_id}/values/'#{sheet_name}'?key=#{sheets_api_key}"
    response = RestClient.get url
    @@data = JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse => e
    # Notificar num log
    @@data = nil
  end

  # Parser (validação de erros)
  def self.parse
    p 'Not Done'
  end

  # Detecção de alarmes (warnings)
  def self.detect_warnings
    p 'Not Done'
  end
end

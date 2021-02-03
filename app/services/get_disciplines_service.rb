# frozen_string_literal: true

require 'rest-client'
require 'json'

class GetDisciplinesService
  def self.run
    request && parse
  end

  def self.request
    sheets_api_key = Rails.application.credentials.google_sheets_API_key
    sheet_id = '1AsmtnS5kY1mhXhNJH5QsCyg_WDnkGtARYB4nMdhyFLs'
    sheet_name = 'DISCIPLINAS'
    url =
      "https://sheets.googleapis.com/v4/spreadsheets/#{sheet_id}/values/
      '#{sheet_name}'?key=#{sheets_api_key}"
    response = RestClient.get url
    @@data = JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse => e
    services_logger.debug "[GetDisciplinesService::request] #{e}"
    @@data = nil
  end

  def self.parse
    raw_disciplines = @@data.slice(1, @@data.size - 1)
    raw_disciplines.each_with_index do |row, index|
      Discipline.create_from(row)
    rescue Mongoid::Errors::Validations => e
      services_logger.debug "[GetDisciplinesService::parse - Linha: #{index + 2}] #{e}"
    end
  end
end

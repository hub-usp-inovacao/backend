# frozen_string_literal: true

require 'rest-client'
require 'json'

class GetDisciplinesService
  def self.run
    request && cleanup && parse && report
  end

  def self.request
    sheets_api_key = ENV['google_sheets_API_key']
    @@sheet_id = ENV['DISCIPLINE_SHEET_ID']
    sheet_name = ENV['DISCIPLINE_TAB_NAME']
    url = "#{base_url}/#{@@sheet_id}/values/'#{sheet_name}'?key=#{sheets_api_key}"
    response = RestClient.get url
    @@data = JSON.parse(response.body)['values']
  rescue RestClient::ExceptionWithResponse => e
    services_logger.debug "[GetDisciplinesService::request] #{e}"
    @@data = nil
  end

  def self.parse
    @@warnings = []
    raw_disciplines = @@data.slice(1, @@data.size - 1)
    raw_disciplines.each_with_index do |row, index|
      Discipline.create_from(row)
    rescue StandardError => e
      e = e.message.gsub(/"|\[|\]/, '')
      warning = "Linha: #{index + 2} - #{e}"
      services_logger.debug "[GetDisciplinesService::parse] - #{warning}"
      @@warnings << warning
    end
  end

  def self.cleanup
    Discipline.where(:created_at.lte => 10.minutes.ago).delete_all
  end

  def self.report
    Report.create({
      entity: 'Disciplinas',
      sheet_id: @@sheet_id,
      warnings: @@warnings
    })
  end

  def self.base_url
    'https://sheets.googleapis.com/v4/spreadsheets'
  end
end

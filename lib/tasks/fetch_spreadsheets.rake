# frozen_string_literal: true

desc 'Fetch data from spreadsheets'
task fetch: :environment do
  p "Fetch task ran! - #{Time.zone.now}"
  GetDisciplinesService.run
end

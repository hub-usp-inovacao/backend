# frozen_string_literal: true

desc 'Fetch data from spreadsheets'
task fetch: :environment do
  GetDisciplinesService.run
end

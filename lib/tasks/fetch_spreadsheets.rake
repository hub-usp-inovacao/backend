# frozen_string_literal: true

desc 'Fetch data from spreadsheets'
task fetch: :environment do
  p "Fetch task running! - #{Time.zone.now}"
  [GetDisciplinesService, GetCompaniesService, GetPatentsService].each do |service|
    service.run
    p "#{service} fetched"
  end
  p "Fetch task ran! - #{Time.zone.now}"
end

# frozen_string_literal: true

desc 'Fetch data from spreadsheets'
task fetch: :environment do
  p "Fetch task running! - #{Time.zone.now}"
  [Discipline, Company, Patent].each do |model|
    GetEntitiesService.run model
    p "#{model.name} fetched"
  end
  p "Fetch task ran! - #{Time.zone.now}"
end

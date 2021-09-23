# frozen_string_literal: true

desc 'Fetch data from spreadsheets with report generation'
task fetch: :environment do
  p "Fetch task running! - #{Time.zone.now}"
  [Discipline, Company, Patent].each do |model|
    GetEntitiesService.run model
    p "#{model.name} fetched"
  end
  p "Fetch task ran! - #{Time.zone.now}"
end

namespace :no_report do
  desc 'Fetch data from spreadsheets without report generation'
  task fetch: :environment do
    p "Fetch task running! - #{Time.zone.now}"
    [Discipline, Company, Patent].each do |model|
      GetEntitiesService.run(model, with_report: false)
      p "#{model.name} fetched"
    end
    p "Fetch task ran! - #{Time.zone.now}"
  end
end

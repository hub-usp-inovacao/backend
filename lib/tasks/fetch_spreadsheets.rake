# frozen_string_literal: true

namespace :fetch do
  desc 'Fetch data from spreadsheets with report generation'
  task report: :environment do
    p "Fetch task running! - #{Time.zone.now}"
    [Discipline, Company, Patent].each do |model|
      GetEntitiesService.run model
      p "#{model.name} fetched"
    end
    p "Fetch task ran! - #{Time.zone.now}"
  end

  desc 'Fetch data from spreadsheets without report generation'
  task no_report: :environment do
    p "Fetch task running! - #{Time.zone.now}"
    [Discipline, Company, Patent].each do |model|
      GetEntitiesService.run(model, with_report: false)
      p "#{model.name} fetched"
    end
    p "Fetch task ran! - #{Time.zone.now}"
  end
end

task fetch: :environment do
  Rake::Task['fetch:report'].invoke
end

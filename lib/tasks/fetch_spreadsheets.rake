# frozen_string_literal: true

def log(task_name, message)
  p "[#{task_name}|#{Time.zone.now}] #{message}"
end

namespace :fetch do
  desc 'Fetch data from spreadsheets with report generation'
  task report: :environment do
    log('fetch', 'task running!')
    [Discipline, Company, Patent, Skill, Iniciative].each do |model|
      GetEntitiesService.run model
      log('fetch', "#{model.name} fetched")
    end
    log('fetch', 'task ran!')
  end

  desc 'Fetch data from spreadsheets without report generation'
  task no_report: :environment do
    log('fetch:no_report', 'task running!')
    [Discipline, Company, Patent, Skill, Iniciative].each do |model|
      GetEntitiesService.run(model, with_report: false)
      log('fetch:no_report', "#{model.name} fetched")
    end
    log('fetch:no_report', 'task ran!')
  end
end

task fetch: :environment do
  Rake::Task['fetch:report'].invoke
end

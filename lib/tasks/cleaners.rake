# frozen_string_literal: true

def log(task_name, message)
  p "[#{task_name}|#{Time.zone.now}] #{message}"
end

desc 'Cleans 2 week old reports that have been already reported'
task clean_reports: :environment do
  log('clean_reports', 'cleaning reports!')
  deleteds = Report.where(:created_at.lte => 2.weeks.ago, delivered: true).delete_all
  log('clean_reports', "#{deleteds} deleted reports!")
end

desc 'Cleans already reported companies updates'
task clean_updates: :environment do
  deleteds = CompanyUpdate.where(delivered: true).delete_all
  p "#{deleteds} Atualizações deletadas!"
end

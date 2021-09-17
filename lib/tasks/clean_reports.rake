# frozen_string_literal: true

desc 'Cleans 2 week old reports that have been already reported'
task clean_reports: :environment do
  deleteds = Report.all.where(:created_at.lte => 2.weeks.ago, delivered: true).delete_all
  p "#{deleteds} Reportes deletados!"
end

# frozen_string_literal: true

desc 'Cleans reports that are 2 weeks dated'
task clean_reports: :environment do
  deleteds = Report.all.where(:created_at.lte => 2.weeks.ago).delete_all
  p "#{deleteds} Reportes deletados!"
end

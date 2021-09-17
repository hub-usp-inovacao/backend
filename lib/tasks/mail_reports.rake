# frozen_string_literal: true

desc 'Sends mails with all the errors not yet reported'
task mail_reports: :environment do
  Report.all.where(delivered: false).each do |report|
    ApplicationMailer.with(warnings: report.warnings, sheet_id: report.sheet_id,
                           entity: report.entity).warnings.deliver_now
    report.delivered = true
    report.save
  end
end

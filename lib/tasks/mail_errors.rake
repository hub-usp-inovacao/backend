# frozen_string_literal: true

desc 'Sends mails with all the errors not yet reported'
task mail_errors: :environment do
  puts CompanyUpdate.all

  CompanyUpdate.delete_all
  Report.all.each do |report|
    ApplicationMailer.with(warnings: report.warnings, sheet_id: report.sheet_id,
                           entity: report.entity).warnings.deliver_now
    report.delivered = true
  end
end

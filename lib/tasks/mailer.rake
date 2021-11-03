# frozen_string_literal: true

def log(task_name, message)
  p "[#{task_name}|#{Time.zone.now}] #{message}"
end

desc 'Sends mails with all the errors not yet reported'
task mail_reports: :environment do
  log('mail_reports', 'mailing reports!')
  Report.where(delivered: false).each do |report|
    ApplicationMailer.with(warnings: report.warnings, sheet_id: report.sheet_id,
                           entity: report.entity).warnings.deliver_now
    report.delivered = true
    report.save
  end
  log('mail_reports', 'reports mailed!')
end

desc 'Reports all updated companies'
task mail_updates: :environment do
  log('report_updates', 'mailing updated companies!')
  ApplicationMailer.update_companies.deliver_now
  log('report_updates', 'updated companies mailed!')
end

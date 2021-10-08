# frozen_string_literal: true

desc 'Sends mails with all the errors not yet reported'
task mail_reports: :environment do
  Report.where(delivered: false).each do |report|
    ApplicationMailer.with(warnings: report.warnings, sheet_id: report.sheet_id,
                           entity: report.entity).warnings.deliver_now
    report.delivered = true
    report.save
  end
end

desc 'Reports all companies updates not yet reported'
task report_updates: :environment do
  companies = CompanyUpdate.where(delivered: false)

  if companies.length.positive?
    ApplicationMailer.with(companies: companies).update_companies.deliver_now

    companies.each do |company|
      company.delivered = true
      company.save
    end
  end
end

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
  log('mail_updates', 'mailing updated companies!')
  new_updates = CompanyUpdate.where(delivered: false)

  if new_updates.length.positive?
    ApplicationMailer.update_companies.deliver_now

    new_updates.each do |company|
      company.delivered = true
      company.save
    end
  end
  log('mail_updates', 'updated companies mailed!')
end

desc 'Reports all new entries in the Conexão usp forms'
task mail_conexao: :environment do
  log('mail_conexao', 'mailing new Conexão USP entries!')
  new_entries = Conexao.where(delivered: false)

  if new_entries.length.positive?
    ApplicationMailer.with(entities: new_entries).conexao.deliver_now

    new_entries.each do |entry|
      entry.delivered = true
      entry.save
    end
  end
  log('mail_conexao', 'new Conexão USP entries mailed!')
end

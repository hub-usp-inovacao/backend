# frozen_string_literal: true

desc 'Reads CompanyUpdate outbox'
task report_outbox: :environment do
  puts CompanyUpdate.all

  CompanyUpdate.delete_all
end

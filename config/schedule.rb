# frozen_string_literal: true

set :output, 'log/whenever.log'
set :environment, ENV['RAILS_ENV']
env :PATH, ENV['PATH']

every :monday, at: '9 am' do
  rake 'fetch'
end

every :monday, at: '09:30 am' do
  rake 'mail_reports'
  rake 'clean_reports'
end

every :monday, at: '11:00 am' do
  rake 'mail_updates'
end

every :day, at: '08:30 pm' do
  rake 'mail_conexao'
end

# frozen_string_literal: true

set :output, 'log/whenever.log'
set :environment, :development
env :PATH, ENV['PATH']

every :monday, at: '9 am' do
  rake 'fetch'
end

every :monday, at: '09:30 am' do
  rake 'mail_reports'
  rake 'clean_reports'
end

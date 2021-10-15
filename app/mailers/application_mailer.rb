# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV['mail_username'],
          to: ENV['mail_username'],
          cc: ENV['mail_dev_username']

  def warnings
    @warnings = params[:warnings]
    @entity = params[:entity]
    @sheet_url = "https://docs.google.com/spreadsheets/d/#{params[:sheet_id]}"
    mail(subject: "Hub USP Inovação - Aviso semanal de #{@entity}")
  end

  def update_companies
    @companies = params[:companies]
    mail(subject: 'Hub USP Inovação - Novas empresas solicitaram atualização dos dados')
  end
end

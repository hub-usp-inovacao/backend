# frozen_string_literal: true

class DisciplineMailer < ApplicationMailer
  default from: ENV['mail_username'],
          to: ENV['mail_username']

  def warnings
    @warnings = params[:warnings]
    @sheet_url = "https://docs.google.com/spreadsheets/d/#{params[:sheet_id]}"
    mail(subject: 'Hub USP Inovação - Aviso semanal de Disciplinas')
  end
end

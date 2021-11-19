# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV['mail_username'],
          to: ENV['mail_username'],
          cc: ENV['mail_dev_username']

  def subject(text)
    "Hub USP Inovação - #{text}"
  end

  def warnings
    @warnings = params[:warnings]
    @entity = params[:entity]
    @sheet_url = "https://docs.google.com/spreadsheets/d/#{params[:sheet_id]}"
    mail(subject: subject("Aviso semanal de #{@entity}"))
  end

  def update_companies
    attachments["updated-companies-#{Time.zone.today}.csv"] =
      { mime_type: 'text/csv', content: CompanyUpdate.to_csv }
    mail(subject: subject('Novas empresas solicitaram atualização dos dados'))
  end

  def conexao
    @entities = params[:entities]

    @personalLabels = ['Nome', 'Email', 'Representa uma']
    @orgLabels = ['Nome', 'Email', 'CNPJ', 'Os dados são sigilosos?', 'Tamanho da empresa',
                  'Telefone', 'Endereço', 'Cidade']
    @demandLabels = ['Descrição', 'Expectativa', 'Perfil de pesquisador desejado',
                     'Qual é a sua necessidade em relação a esses pesquisadores?']

    mail(subject: subject('Novas demandas foram solicitadas no Conexão USP'))
  end
end

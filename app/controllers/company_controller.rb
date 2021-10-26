# frozen_string_literal: true

class CompanyController < ApplicationController
  def index
    if params.key? :cnpj
      find_one
    else
      all
    end
  end

  private

  def all
    @companies = Company.all
    render json: @companies, status: :ok
  end

  def find_one
    cnpj = params[:cnpj]
    @company = Company.find_by! cnpj: cnpj
    render json: @company, status: :ok
  rescue StandardError
    render json: { error: :not_found }, status: :not_found
  end
end

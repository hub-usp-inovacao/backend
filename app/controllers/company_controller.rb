# frozen_string_literal: true

class CompanyController < ApplicationController
  def index
    @companies = Company.all
    render json: @companies, status: :ok
  end
end

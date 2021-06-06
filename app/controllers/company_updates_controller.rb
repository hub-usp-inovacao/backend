# frozen_string_literal: true

class CompanyUpdatesController < ApplicationController
  def create
    data = create_params
    @comp_update = CompanyUpdate.create!(data)
    render json: { company_update: @comp_update }
  rescue StandardError
    render json: { error: 'invalid parameters' }, status: :bad_request
  end

  private

  def create_params
    params.require(:company).permit(:cnpj, :new_fields)
  end
end

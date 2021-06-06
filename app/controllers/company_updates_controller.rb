class CompanyUpdatesController < ApplicationController
  def create
    data = create_params
    p data
    @compUpdate = CompanyUpdate.create!(data)
    render json: { company_update: @compUpdate }
  rescue StandardError => e
    render json: { error: 'invalid parameters' }, status: :bad_request
  end

  private

  def create_params
    params.require(:company).permit(:cnpj, :new_fields)
  end
end

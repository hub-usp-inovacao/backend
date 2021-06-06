# frozen_string_literal: true

class CompanyUpdatesController < ApplicationController
  def create
    ActionController::Parameters.permit_all_parameters = true
    data = create_params
    @comp_update = CompanyUpdate.create!(data)
    render json: { company_update: @comp_update }
  rescue StandardError => e
    render json: { error: e }, status: :bad_request
  end

  private

  def create_params
    params.require(:company)
  end
end

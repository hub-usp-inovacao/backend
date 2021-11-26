# frozen_string_literal: true

class CompanyUpdatesController < ApplicationController
  def create
    ActionController::Parameters.permit_all_parameters = true
    data = create_params
    @comp_update = CompanyUpdate.new(data)
    if @comp_update.valid?
      @comp_update.save
      render json: { company_update: @comp_update }
    else
      render json: { error: @comp_update.errors.full_messages }, status: :bad_request
    end
  end

  private

  def create_params
    params.require(:company)
  end
end

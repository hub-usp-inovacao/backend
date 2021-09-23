# frozen_string_literal: true

class PatentController < ApplicationController
  def index
    @patents = Patent.all
    render json: @patents, status: :ok
  end
end

# frozen_string_literal: true

class DisciplineController < ApplicationController
  def index
    @disciplines = Discipline.all
    render json: @disciplines, status: :ok
  end
end

class DisciplineController < ApplicationController
  def index
    @disciplines = Discipline.all
    render json: @disciplines, status: 200
  end
end

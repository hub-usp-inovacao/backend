# frozen_string_literal: true

class IniciativeController < ApplicationController
  def index
    @iniciatives = Iniciative.all
    render json: @iniciatives
  end
end

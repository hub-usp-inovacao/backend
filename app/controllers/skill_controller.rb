# frozen_string_literal: true

class SkillController < ApplicationController
  def index
    @skills = Skill.all
    render json: @skills, status: :ok
  end
end

# frozen_string_literal: true

class ConexoesController < ApplicationController
  def create
    @conexao = Conexao.create!(create_params)
    render json: { conexao: @conexao }
  rescue StandardError => e
    render json: { error: e }, status: :bad_request
  end

  def create_image
    id = params[:requestId]
    image = params[:image]

    instance = Conexao.find_by!(requestId: id)
    @image = Image.new(content: image)
    instance.images.push(@image)

    @image.save!
    instance.save!

    render status: :created
  rescue StandardError => e
    render json: { error: e }, status: :bad_request
  end

  private

  def create_params
    params.require(:conexao).permit(:requestId, personal: {}, org: {}, demand: {})
  end

  def images_params
    params.permit(:requestId, :image)
  end
end

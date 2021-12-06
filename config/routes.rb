# frozen_string_literal: true

Rails.application.routes.draw do
  get '/disciplines', to: 'discipline#index'
  get '/companies', to: 'company#index'
  get '/patents', to: 'patent#index'
  get '/skills', to: 'skill#index'
  patch '/companies', to: 'company_updates#create'
  post '/conexao', to: 'conexoes#create'
  post '/conexao/image', to: 'conexoes#create_image'
end

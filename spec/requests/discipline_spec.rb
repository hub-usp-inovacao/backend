# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Disciplines', type: :request do
  def discipline_keys
    %w[_id name campus unity start_date
       nature level url description
       category keywords created_at]
  end

  describe 'GET /index' do
    before do
      get '/disciplines'
    end

    it 'returns a response with success http status' do
      expect(response).to have_http_status(:success)
    end

    it 'returns a list of all disciplines with expected format' do
      resp = JSON.parse(response.body)
      resp.each do |discipline|
        expect(discipline.keys.difference(discipline_keys)).to eq([])
      end
    end
  end
end

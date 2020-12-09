require 'rails_helper'

RSpec.describe "Discipline", type: :request do
  describe 'GET /disciplines' do
    before(:each) { get '/disciplines' }

    it 'returns success' do
      expect(response).to have_http_status(:success)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GetDisciplinesService, type: :model do
  describe 'GetDisciplinesService::request' do
    before do
      @response = GetDisciplinesService.request
    end

    it 'get status 200' do
      expect(@response).to be_truthy
    end
  end
end

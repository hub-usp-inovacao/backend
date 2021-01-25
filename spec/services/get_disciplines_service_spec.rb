# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GetDisciplinesService, type: :model do
  describe 'GetDisciplinesService::request' do
    before do
      mock_response = instance_double(RestClient::Response,
                                      body: {
                                        'isAvailable' => true,
                                        'imageAvailable' => false,
                                      }.to_json)

      allow(RestClient::Request).to receive(:execute).and_return(mock_response)

      @response = GetDisciplinesService.request
    end

    it 'get status 200' do
      expect(@response).to be_truthy
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Patents', type: :request do
  let :valid_attr do
    {
      name: 'Modificação operacional de condutivimetro para medida analógica direta',
      summary: 'foo bar baz baz bar baz',
      classification: {
        primary: {
          cip: 'G - Física',
          subarea: 'G01 - Medição; teste'
        },
        secondary: {
          cip: 'G - Física',
          subarea: 'G01 - Medição; teste'
        }
      },
      ipcs: %w[G01N002706 G01N003318 G01R002722],
      owners: ['Univ. São Paulo'],
      status: 'Domínio Público',
      url: 'https://www.derwentinnovation.com/tip-innovation/externalLink.do?data=eEO7KvKuA%2BZmPC8utuUqQr7lxA0syEOxG1yqA8aIDa%2FHR0Yfnr7aHsH4I3OaAA37ytEXegSSxUP88PZ%2FJk5CQ0F4IIj6EeeZd%2Fly4xNtak9D2Ijuz2cF9Rr1PHQZYuFqg%2FYNe5%2BU%2F6zBxsQ4e9T6wcUaS6C2iUdS1Quy3oxeQInFAX0jXNFh7mzwKSn8aGG4VzpPdJ%2BnHJF%2BMRoOami4RIjq7tjlEE9JGV%2BNkVHomAIZzfHxG4IyIQtFFyh2ZmyyAvka04VEc0mfBtPA5xYZ5A%3D%3D&code=4c2c69ca2e3d1b11af22306222240f03',
      inventors: ['Lelio Favaretto'],
      countries_with_protection: ['Brasil'],
      photo: 'https://drive.google.com/uc?export=view&id=1cmsUahKZ6fMsat4P9QFWyOM9T9CWA-cw'
    }
  end

  def patent_keys
    %w[_id name summary classification ipcs owners
       status url inventors countries_with_protection
       photo created_at]
  end

  describe 'GET /index' do
    before do
      Patent.create(valid_attr)
      get '/patents'
    end

    it 'returns a response with success http status' do
      expect(response).to have_http_status(:success)
    end

    it 'returns a list of all patents with expected format' do
      resp = JSON.parse(response.body)
      resp.each do |patent|
        expect(patent.keys.difference(patent_keys)).to eq([])
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Skill, type: :model do
  let :valid_attr do
    {
      name: 'Alfredo Goldman',
      email: 'gold@ime.usp.br',
      unities: ['Instituto de Matemática e Estatística'],
      campus: 'Butantã',
      labs_or_groups: [],
      description: {},
      area: {},
      phone: '(11) 3091-6497',
      keywords: ['high performance computing', 'agile methodologies'],
      lattes: 'http://lattes.cnpq.br/2118391660819227',
      picture: '',
      limit_date: '',
      bond: 'Docente'
    }
  end

  it 'is a placeholder' do
    expect(1 + 1).to be(2)
  end
end

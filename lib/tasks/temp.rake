# frozen_string_literal: true

task fix_company_data: :environment do
  @companies = CompanyUpdate.all
  @companies.each do |company|
    if ( company.company_values.key? :CNAE)
      company.company_values[:cnae] = company.company_values[:CNAE]
      company.company_values.delete(:CNAE)
    end
    company.company_values[:Endereço] = company.company_values[:Endereço][:venue] if company.company_values[:Endereço].is_a? Hash
    company.company_values['Breve descrição'.to_sym] = company.company_values['Breve descrição'.to_sym][:long] if company.company_values['Breve descrição'.to_sym].is_a? Hash
    company.save
  end
end

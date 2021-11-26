# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'

require 'i18n/backend/fallbacks'
I18n::Backend::Simple.include I18n::Backend::Fallbacks

Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    config.i18n.fallbacks = { 'pt-br' => 'en' }
    config.load_defaults 6.0

    config.api_only = true

    config.action_mailer.raise_delivery_errors = true

    config.action_mailer.perform_caching = false

    config.action_mailer.delivery_method = :smtp

    config.action_mailer.smtp_settings = {
      address: 'smtp.gmail.com',
      port: 587,
      domain: 'hubusp.inovacao.usp.br',
      user_name: ENV['email_username'],
      password: ENV['email_password'],
      authentication: 'plain',
      enable_starttls_auto: true
    }

    config.i18n.default_locale = :"pt-br"
  end
end

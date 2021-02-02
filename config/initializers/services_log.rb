# frozen_string_literal: true

require 'logger'

$logger = Logger.new('log/services.log')

def services_logger
  $logger
end

# frozen_string_literal: true

require 'roda'
require 'json'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    route('auth') do |routing|
      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          input_data = JSON.parse(request.body.read)
          credentials = input_data.transform_keys(&:to_sym)
          auth_account = AuthenticateAccount.call(credentials)
          auth_account.to_json
        rescue UnauthorizedError => e
          puts [e.class, e.message].join ': '
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end
    end
  end
end

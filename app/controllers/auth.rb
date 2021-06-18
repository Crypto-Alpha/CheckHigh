# frozen_string_literal: true

require 'roda'
require 'json'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    route('auth') do |routing|
      routing.on 'register' do
        # POST api/v1/auth/register
        routing.post do
          reg_data = JsonRequestBody.parse_symbolize(request.body.read)
          VerifyRegistration.new(reg_data).call

          response.status = 202
          { message: 'Verification email sent' }.to_json
        rescue VerifyRegistration::InvalidRegistration => e
          routing.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          puts "ERROR VERIFYING REGISTRATION: #{e.inspect}"
          puts e.message
          routing.halt 500
        end
      end

      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          auth_account = AuthenticateAccount.call(credentials)
          { data: auth_account }.to_json
        rescue AuthenticateAccount::UnauthorizedError => e
          puts [e.class, e.message].join ': '
          routing.halt 401, { message: 'Invalid credentials' }.to_json
        end
      end

      routing.on 'sso' do
      # POST /api/v1/auth/sso
        routing.post do
          auth_request = JsonRequestBody.parse_symbolize(request.body.read)

          auth_account = AuthorizeSso.new.call(auth_request[:access_token])
          { data: auth_account }.to_json
        rescue AuthorizeSso::UnauthorizedError => e
          puts [e.class, e.message].join ': '
          routing.halt 401, { message: 'Invalid credentials' }.to_json
        rescue StandardError => e
          puts "FAILED to validate Github account: #{e.inspect}"
          puts e.backtrace
          routing.halt 400
        end
      end
    end
  end
end

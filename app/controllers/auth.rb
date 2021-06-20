# frozen_string_literal: true

require 'roda'
require 'json'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    route('auth') do |routing|
      # All requests in this route require signed requests
      begin
        @request_data = SignedRequest.new(Api.config).parse(request.body.read)
      rescue SignedRequest::VerificationError
        routing.halt 403, { message: 'Must sign request'}.to_json
      end

      routing.on 'register' do
        # POST api/v1/auth/register
        routing.post do
          VerifyRegistration.new(@request_data).call

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
          auth_account = AuthenticateAccount.call(@request_data)
          { data: auth_account }.to_json
        rescue AuthenticateAccount::UnauthorizedError => e
          puts [e.class, e.message].join ': '
          routing.halt 401, { message: 'Invalid credentials' }.to_json
        end
      end

      # POST /api/v1/auth/github_sso
      routing.on 'github_sso' do
        routing.post do
          auth_account = AuthorizeSso.new.call(@request_data[:access_token])
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

      # POST /api/v1/auth/google_sso
      routing.on 'google_sso' do
        routing.post do
          auth_account = AuthorizeGoogleSso.new.call(@request_data[:id_token], @request_data[:aud])
          { data: auth_account }.to_json
        rescue AuthorizeGoogleSso::UnauthorizedError => e
          puts [e.class, e.message].join ': '
          routing.halt 401, { message: 'Invalid credentials' }.to_json
        rescue StandardError => e
          puts "FAILED to validate Google account: #{e.inspect}"
          puts e.backtrace
          routing.halt 400
        end
      end

      # POST api/v1/auth/resetpwd
      routing.on 'resetpwd' do
        routing.post do
          VerifyResetPwd.new(@request_data).call

          response.status = 202
          { message: 'Verification email sent' }.to_json
        rescue VerifyResetPwd::InvalidResetPwd => e
          routing.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          puts "ERROR VERIFYING REGISTRATION: #{e.inspect}"
          puts e.message
          routing.halt 500
        end
      end

      # POST /api/v1/auth/username
      routing.on 'username' do
        routing.post do
          auth_resetpwd_account = GetUsername.call(@request_data)
          { data: auth_resetpwd_account }.to_json
        rescue GetUsername::NotFoundError => e
          puts [e.class, e.message].join ': '
          routing.halt 404, { message: 'Invalid account of email' }.to_json
        end
      end
    end
  end
end

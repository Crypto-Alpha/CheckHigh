# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      # POST api/v1/accounts/resetpwd
      routing.on 'resetpwd' do
        routing.post do
          account_data = SignedRequest.new(Api.config).parse(request.body.read)
          account = Account.find(email: account_data[:email]).update(account_data)

          response.status = 201
          response['Location'] = "#{@account_route}/#{account.username}"
          { message: 'Account saved', data: account }.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue SignedRequest::VerificationError
          routing.hatl 403, { message: 'Must sign request' }.to_json
        rescue StandardError => e
          puts "ERROR CREATING ACCOUNT: #{e.inspect}"
          routing.halt 500, { message: 'Error creating account' }.to_json
        end
      end

      # GET api/v1/accounts/[username]
      routing.on String do |username|
        routing.halt(403, UNAUTH_MSG) unless @auth_account

        routing.get do
          auth = AuthorizeAccount.call(
            auth: @auth, username: username,
            auth_scope: AuthScope.new(AuthScope::READ_ONLY)
          )
          { data: auth }.to_json
        rescue AuthorizeAccount::ForbiddenError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET ACCOUNT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API Server Error' }.to_json
        end
      end

      # POST api/v1/accounts
      routing.post do
        account_data = SignedRequest.new(Api.config).parse(request.body.read)
        new_account = CreateAccount.new(account_data).call

        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.username}"
        { message: 'Account saved', data: new_account }.to_json
      rescue CreateAccount::InvalidRegistration => e
        puts [e.class, e.message].join ': '
        routing.halt 400, { message: e.message }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue SignedRequest::VerificationError
        routing.hatl 403, { message: 'Must sign request' }.to_json
      rescue StandardError => e
        puts "ERROR CREATING ACCOUNT: #{e.inspect}"
        routing.halt 500, { message: 'Error creating account' }.to_json
      end
    end
  end
end

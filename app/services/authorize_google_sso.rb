# frozen_string_literal: true

require 'google-id-token'
require 'http'

module CheckHigh
  # Find or create an SsoAccount based on Google code
  class AuthorizeGoogleSso
    # Error for no email adress to login
    class UnauthorizedError < StandardError
      def message
        'Invalid Credentials: No Email Address.'
      end
    end

    def call(id_token, aud)
      google_account = get_google_account(id_token, aud)
      sso_account = find_or_create_sso_account(google_account)

      account_and_token(sso_account)
    end

    def domain_available?(iss)
      iss.include?(config.GOOGLE_ACCOUNT_DOMAIN)
    end

    def expire?(exp)
      exp > Time.now.to_i
    end

    def get_google_account(id_token, aud)
      raise UnauthorizedError unless aud == config.GOOGLE_CLIENT_ID

      payload = GoogleIDToken::Validator.new.check(id_token, aud)
      raise UnauthorizedError unless domain_available?(payload['iss'])
      raise UnauthorizedError unless expire?(payload['exp'])

      { username: payload['email'].split('@').first, email: payload['email'] }
    end

    def find_or_create_sso_account(account_data)
      exist = Account.first(email: account_data[:email])
      if exist.nil?
        new_account = Account.create_github_account(account_data)
        CreateAccountExample.call(new_account)
      else
        exist
      end
    end

    def account_and_token(account)
      {
        type: 'sso_account',
        attributes: {
          account: account,
          auth_token: AuthToken.create(account)
        }
      }
    end

    private

    def config
      Api.config
    end
  end
end

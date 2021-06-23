# frozen_string_literal: true

require 'google-id-token'
require 'http'

module CheckHigh
  # Find or create an SsoAccount based on Google code
  class AuthorizeGoogleSso
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

    def get_google_account(id_token, aud)
      validator = GoogleIDToken::Validator.new
      raise UnauthorizedError unless aud == config.GOOGLE_CLIENT_ID

      payload = validator.check(id_token, aud)

      raise UnauthorizedError unless payload['iss'].include?(config.GOOGLE_ACCOUNT_DOMAIN)
      raise UnauthorizedError unless payload['exp'] > Time.now.to_i

      email = payload['email']
      username = email.split('@').first

      { username: username, email: email }
    end

    def find_or_create_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        Account.create_google_account(account_data)
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

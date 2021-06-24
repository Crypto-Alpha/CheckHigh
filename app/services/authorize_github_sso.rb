# frozen_string_literal: true

require 'http'

module CheckHigh
  # Find or create an SsoAccount based on Github code
  class AuthorizeGithubSso
    # no public email in github user account
    class UnauthorizedError < StandardError
      def message
        'Invalid Credentials: No Email Address.'
      end
    end

    def call(access_token)
      github_account = get_github_account(access_token)
      sso_account = find_or_create_sso_account(github_account)

      account_and_token(sso_account)
    end

    def get_github_account(access_token)
      gh_response = HTTP.headers(
        user_agent: 'CheckHigh',
        authorization: "token #{access_token}",
        accept: 'application/json'
      ).get(ENV['GITHUB_ACCOUNT_URL'])

      raise unless gh_response.status == 200

      account = GithubAccount.new(JSON.parse(gh_response))
      raise UnauthorizedError unless account.email

      { username: account.username, email: account.email }
    end

    def find_or_create_sso_account(account_data)
      exist = Account.first(email: account_data[:email])
      unless !exist.nil?
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
  end
end

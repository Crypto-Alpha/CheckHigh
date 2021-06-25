# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require 'simplecov'
SimpleCov.start

require_relative 'test_load_all'

def wipe_database
  CheckHigh::Account.map(&:destroy)
  CheckHigh::Assignment.map(&:destroy)
  CheckHigh::ShareBoard.map(&:destroy)
  CheckHigh::Course.map(&:destroy)
end

def authenticate(account_data)
  CheckHigh::AuthenticateAccount.call(
    email: account_data['email'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  contents = AuthToken.contents(auth[:attributes][:auth_token])
  account = contents['payload']['attributes']
  { account: CheckHigh::Account.first(email: account['email']),
    scope: AuthScope.new(contents['scope']) }
end

DATA = {
  accounts: YAML.load(File.read('app/db/seeds/account_seeds.yml')),
  assignments: YAML.load(File.read('app/db/seeds/assignment_seeds.yml')),
  share_boards: YAML.load(File.read('app/db/seeds/share_board_seeds.yml')),
  courses: YAML.load(File.read('app/db/seeds/course_seeds.yml')),
  owned_assignments: YAML.load(File.read('app/db/seeds/owners_assignments.yml'))
}.freeze

## Github SSO fixtures
GH_ACCOUNT_RESPONSE = YAML.load(
  File.read('spec/fixtures/github_token_response.yml')
)
GOOD_GH_ACCESS_TOKEN = GH_ACCOUNT_RESPONSE.keys.first
GH_SSO_ACCOUNT = YAML.load(File.read('spec/fixtures/sso_github_accounts.yml'))

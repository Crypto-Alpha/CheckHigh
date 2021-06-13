# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  CheckHigh::Account.map(&:destroy)
  CheckHigh::Assignment.map(&:destroy)
  CheckHigh::ShareBoard.map(&:destroy)
  CheckHigh::Course.map(&:destroy)
end

def auth_header(account_data)
  auth = CheckHigh::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {
  accounts: YAML.load(File.read('app/db/seeds/account_seeds.yml')),
  assignments: YAML.load(File.read('app/db/seeds/assignment_seeds.yml')),
  share_boards: YAML.load(File.read('app/db/seeds/share_board_seeds.yml')),
  courses: YAML.load(File.read('app/db/seeds/course_seeds.yml')),
  owned_assignments: YAML.load(File.read('app/db/seeds/owners_assignments.yml'))
}.freeze

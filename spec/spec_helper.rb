# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:accounts].delete
  app.DB[:assignments].delete
  app.DB[:share_boards].delete
  app.DB[:courses].delete
  # app.DB[:dashboards].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/account_seeds.yml')
DATA[:assignments] = YAML.safe_load File.read('app/db/seeds/assignment_seeds.yml')
DATA[:share_boards] = YAML.safe_load File.read('app/db/seeds/share_board_seeds.yml')
DATA[:courses] = YAML.safe_load File.read('app/db/seeds/course_seeds.yml')
# DATA[:dashboards] = YAML.safe_load File.read('app/db/seeds/dashboard_seeds.yml')

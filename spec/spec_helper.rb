# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:accounts].delete
  app.DB[:assignments].delete
  app.DB[:shareboards].delete
  app.DB[:courses].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/account_seeds.yml')
DATA[:assignments] = YAML.safe_load File.read('app/db/seeds/assignment_seeds.yml')
DATA[:shareboards] = YAML.safe_load File.read('app/db/seeds/shareboard_seeds.yml')
DATA[:courses] = YAML.safe_load File.read('app/db/seeds/course_seeds.yml')

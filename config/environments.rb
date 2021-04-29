# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'sequel'

module CheckHigh
  # Configuration for the API
  class Api < Roda
    plugin :environments

    Figaro.application = Figaro::Application.new(
      environment: environment,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load

    # Make the environment variables accessible to other classes
    def self.config
      Figaro.env
    end

    DB = Sequel.connect(config.DATABASE_URL)

    # Make the database accessible to other classes
    def self.DB # rubocop:disable Naming/MethodName
      DB
    end

    configure :development, :test do
      require 'pry'
    end
  end
end

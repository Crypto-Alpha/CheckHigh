# frozen_string_literal: true

require 'http'

module CheckHigh
  # register by invitation email
  class CreateAccount
    class InvalidRegistration < StandardError; end

    def initialize(registration)
      @registration = registration
    end

    def call
      raise(InvalidRegistration, 'Username exists') unless username_available?

      Account.create(@registration)
    end

    def username_available?
      Account.first(username: @registration[:username]).nil?
    end
  end
end

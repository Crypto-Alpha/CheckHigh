# frozen_string_literal: true

module CheckHigh
  # Find account and give back username
  class GetUsername
    # Error for cannot find a account
    class NotFoundError < StandardError
      def initialize(msg = nil)
        super
        @credentials = msg
      end

      def message
        "We could not find account of #{@credentials[:email]}"
      end
    end

    def self.call(credentials)
      account = Account.first(email: credentials[:email])
      raise NotFoundError if account.nil?

      {
        type: 'username',
        attributes: {
          username: account.username
        }
      }
    rescue StandardError
      raise(NotFoundError, credentials)
    end
  end
end

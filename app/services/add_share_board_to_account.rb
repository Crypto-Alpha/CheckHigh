# frozen_string_literal: true

module CheckHigh
  # Create new share board for an account
  class CreateShareBoardForAccount
    def self.call(account_id:, shareboard_data:)
      Account.find(id: account_id)
             .add_owned_share_board(shareboard_data)
    end
  end
end

# frozen_string_literal: true

module CheckHigh
  # Create new share board for an owner
  class CreateShareBoardForOwner
    def self.call(owner_id:, share_board_data:)
      Account.find(id: owner_id)
             .add_owned_share_board(share_board_data)
    end
  end
end

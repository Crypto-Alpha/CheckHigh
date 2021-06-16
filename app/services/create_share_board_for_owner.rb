# frozen_string_literal: true

module CheckHigh
  # Create new share board for an owner
  class CreateShareBoardForOwner
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more documents'
      end
    end

    def self.call(auth:, share_board_data:)
      raise ForbiddenError unless auth[:scope].can_write?('share_boards')

      auth[:account].add_owned_share_board(share_board_data)
    end
  end
end

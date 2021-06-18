# frozen_string_literal: true

module CheckHigh
  # Rename share board's name 
  class RenameShareBoard
    # Error for access that share board 
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that share board'
      end
    end

    # Error for cannot find a share board
    class NotFoundError < StandardError
      def message
        'We could not find that share board'
      end
    end

    # Share board for given requestor account
    def self.call(auth:, share_board:, new_name:)
      raise NotFoundError unless share_board

      policy = ShareBoardPolicy.new(auth[:account], share_board, auth[:scope])
      raise ForbiddenError unless policy.can_edit?

      share_board.update(share_board_name: new_name)
    end
  end
end

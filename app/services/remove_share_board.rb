# frozen_string_literal: true

module CheckHigh
  # Remove an share board
  class RemoveShareBoard
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that share board'
      end
    end

    # Error for cannot find a share board
    class NotFoundError < StandardError
      def message
        'We could not find that share board'
      end
    end

    def self.call(auth:, share_board:)
      raise NotFoundError unless share_board

      policy = ShareBoardPolicy.new(auth[:account], share_board, auth[:scope])
      raise ForbiddenError unless policy.can_delete?

      share_baord.remove_all_assignments
      auth[:account].remove_owned_share_board(share_board)

      #TODO: share board cannot be removed (sqlite foreign constraints) (wait for solutions)
      #deleted_share_board = share_board.delete
      #deleted_share_board
    end
  end
end

# frozen_string_literal: true

module CheckHigh
  # Add a collaborator to another owner's existing share_board
  class GetShareBoardQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that share_board'
      end
    end

    # Error for cannot find a share_board
    class NotFoundError < StandardError
      def message
        'We could not find that share_board'
      end
    end

    def self.call(account:, share_board:)
      raise NotFoundError unless share_board

      policy = ShareBoardPolicy.new(account, share_board)
      raise ForbiddenError unless policy.can_view?

      share_board.full_details.merge(policies: policy.summary)
    end
  end
end

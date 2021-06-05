# frozen_string_literal: true

module CheckHigh
  # Add a collaborator to another owner's existing share_board
  class AddCollaboratorToShareBoard
    # Error for owner cannot be collaborator
    class OwnerNotCollaboratorError < StandardError
      def message = 'Owner cannot be collaborator of share_board'
    end

    def self.call(email:, share_board_id:)
      collaborator = Account.first(email: email)
      share_board = ShareBoard.first(id: share_board_id)
      raise(OwnerNotCollaboratorError) if share_board.owner_share_board_id == collaborator.id

      share_board.add_collaborator(collaborator)
      collaborator
    end
  end
end

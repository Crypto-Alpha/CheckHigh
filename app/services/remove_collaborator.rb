# frozen_string_literal: true

module CheckHigh
  # Delete a collaborator from owner's existing project
  class RemoveCollaborator
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(req_username:, collab_email:, share_board_id:)
      account = Account.first(username: req_username)
      share_board = ShareBoard.first(id: share_board_id)
      collaborator = Account.first(email: collab_email)

      policy = CollaborationRequestPolicy.new(share_board, account, collaborator)
      raise ForbiddenError unless policy.can_remove?

      share_board.remove_collaborator(collaborator)
      collaborator
    end
  end
end

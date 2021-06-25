# frozen_string_literal: true

module CheckHigh
  # Delete a collaborator from owner's existing share board
  class RemoveCollaborator
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.removing(share_board, collaborator)
      share_board.remove_collaborator(collaborator)
      share_board.assignments.each do |assi|
        share_board.remove_assignment(assi) if assi.owner == collaborator
      end
    end

    def self.call(auth:, collab_email:, share_board_id:)
      share_board = ShareBoard.first(id: share_board_id)
      collaborator = Account.first(email: collab_email)

      policy = CollaborationRequestPolicy.new(
        share_board, auth[:account], collaborator, auth[:scope]
      )
      raise ForbiddenError unless policy.can_remove? || policy.can_leave?

      removing(share_board, collaborator)
      collaborator
    end
  end
end

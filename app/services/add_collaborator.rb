# frozen_string_literal: true

require_relative '../policies/collaboration_request_policy'

module CheckHigh
  # Add a collaborator to another owner's existing share_board
  class AddCollaborator
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as collaborator'
      end
    end

    def self.call(auth:, share_board:, collab_email:)
      invitee = Account.first(email: collab_email)
      policy = CollaborationRequestPolicy.new(
        share_board, auth[:account], invitee, auth[:scope]
      )
      raise ForbiddenError unless policy.can_invite?

      share_board.add_collaborator(invitee)
      invitee
    end
  end
end

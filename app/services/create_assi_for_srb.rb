# frozen_string_literal: true

require_relative '../policies/share_board_policy'

module CheckHigh
  # Create new assignments for a share board
  class CreateAssiForSrb
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more assignments'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a assignment with those attributes'
      end
    end

    def self.call(auth:, share_board:, assignment_data:)
      policy = ShareBoardPolicy.new(auth[:account], share_board, auth[:scope])
      raise ForbiddenError unless policy.can_add_assignments?

      share_board.add_assignment(assignment_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end

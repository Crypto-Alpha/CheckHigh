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

    def self.call(account:, share_board:, assignment_data:)
      policy = ShareBoardPolicy.new(account, share_board)
      raise ForbiddenError unless policy.can_add_assignments?

      add_assignment(share_board, assignment_data)
    end

    def self.add_assignment(share_board, assignment_data)
      share_board.add_assignment(assignment_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end

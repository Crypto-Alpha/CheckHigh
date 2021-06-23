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

      assi = share_board.add_assignment(assignment_data)
      # Here only returns assignment metadata info
      Assignment.select(:id, :owner_id, :course_id, :assignment_name, :created_at, :updated_at).where(id: assi.id).first
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end

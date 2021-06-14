# frozen_string_literal: true

module CheckHigh
  # Remove an assignment
  class RemoveAssignment
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that assignment'
      end
    end

    # Error for cannot find an assignment
    class NotFoundError < StandardError
      def message
        'We could not find that assignment'
      end
    end

    def self.call(requestor:, assignment:)
      raise NotFoundError unless assignment
      policy = AssignmentPolicy.new(requestor, assignment)
      raise ForbiddenError unless policy.can_delete?

      deleted_assignment = assignment.delete
      deleted_assignment
    end
  end
end

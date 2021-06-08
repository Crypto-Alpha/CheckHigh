# frozen_string_literal: true

module CheckHigh
  # Add a collaborator to another owner's existing course
  class GetAssignmentQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that assignment'
      end
    end

    # Error for cannot find a course
    class NotFoundError < StandardError
      def message
        'We could not find that assignment'
      end
    end

    # Assignment for given requestor account
    def self.call(requestor:, assignment:)
      raise NotFoundError unless assignment
      policy = AssignmentPolicy.new(requestor, assignment)
      raise ForbiddenError unless policy.can_view?

      assignment
    end
  end
end

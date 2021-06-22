# frozen_string_literal: true

module CheckHigh
  # Rename assignment's name
  class RenameAssignment
    # Error for access that assignment
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that assignment'
      end
    end

    # Error for cannot find a assignment
    class NotFoundError < StandardError
      def message
        'We could not find that assignment'
      end
    end

    # Assignment for given requestor account
    def self.call(auth:, assignment:, new_name:)
      raise NotFoundError unless assignment

      policy = AssignmentPolicy.new(auth[:account], assignment, auth[:scope])
      raise ForbiddenError unless policy.can_edit?

      new_assignment = assignment.update(assignment_name: new_name)

      new_assignment.full_details.merge(policies: policy.summary)
    end
  end
end

# frozen_string_literal: true
require_relative 'remove_course'

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

      # remove from share boards
      assignment.remove_all_share_boards
      # remove from course
      if assignment.course != nil then assignment.course.remove_assignment(assignment) end
      requestor.remove_owned_assignment(assignment)

      #TODO: assignment cannot be removed (sqlite foreign constraints) (wait for solutions)
      #deleted_assignment = assignment.delete
      #deleted_assignment
    end

    def self.call_for_course(requestor:, course:, assignment:)
      raise NotFoundError unless assignment
      raise RemoveCourse::NotFoundError unless course
      policy = AssignmentPolicy.new(requestor, assignment)
      raise ForbiddenError unless policy.can_delete?
     
      # Remove assignment from a course 
      course.remove_assignment(assignment)
    end
  end
end

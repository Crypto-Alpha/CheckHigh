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

    def self.call(auth:, assignment:)
      raise NotFoundError unless assignment

      policy = AssignmentPolicy.new(auth[:account], assignment, auth[:scope])
      raise ForbiddenError unless policy.can_delete?


      # real delete
      deleted_assignment = assignment.destroy
    end

    def self.call_for_course(auth:, course:, assignment:)
      raise NotFoundError unless assignment
      raise RemoveCourse::NotFoundError unless course

      policy = AssignmentPolicy.new(auth[:account], assignment, auth[:scope])
      raise ForbiddenError unless policy.can_delete?
     
      # Remove assignment from a course 
      course.remove_assignment(assignment)
    end

    def self.call_for_share_board(auth:, share_board:, assignment:)
      raise NotFoundError unless assignment
      raise RemoveShareBoard::NotFoundError unless share_board

      policy = AssignmentPolicy.new(auth[:account], assignment, auth[:scope])
      raise ForbiddenError unless policy.can_delete?
     
      # Remove assignment from a share board
      share_board.remove_assignment(assignment)
    end
  end
end

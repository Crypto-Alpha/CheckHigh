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
      destroy_assi = assignment.destroy
      # get destroy assi metadata
      { 
        id: destroy_assi.id,
        owner_id: destroy_assi.owner_id,
        assignment_name: destroy_assi.assignment_name,
        course_id: destroy_assi.course_id,
        created_at: destroy_assi.created_at, 
        updated_at: destroy_assi.updated_at 
      }
    end

    def self.call_for_course(auth:, course:, assignment:)
      raise NotFoundError unless assignment
      raise RemoveCourse::NotFoundError unless course

      policy = AssignmentPolicy.new(auth[:account], assignment, auth[:scope])
      raise ForbiddenError unless policy.can_delete?

      # Remove assignment from a course
      assi = course.remove_assignment(assignment)
      # Here only returns assignment metadata info
      Assignment.select(:id, :owner_id, :course_id, :assignment_name, :created_at, :updated_at).where(id: assi.id).first
    end

    def self.call_for_share_board(auth:, share_board:, assignment:)
      raise NotFoundError unless assignment
      raise RemoveShareBoard::NotFoundError unless share_board

      policy = AssignmentPolicy.new(auth[:account], assignment, auth[:scope])
      raise ForbiddenError unless policy.can_delete?

      # Remove assignment from a share board
      assi = share_board.remove_assignment(assignment)
      # Here only returns assignment metadata info
      Assignment.select(:id, :owner_id, :course_id, :assignment_name, :created_at, :updated_at).where(id: assi.id).first
    end
  end
end

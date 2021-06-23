# frozen_string_literal: true

require_relative '../policies/account_policy'

module CheckHigh
  # Create new assignment for an owner
  class CreateAssiForOwner
    # Error for owner cannot create assignment
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

    def self.call(auth:, assignment_data:)
      raise ForbiddenError unless auth[:scope].can_write?('assignments')

      # check if assignment name is the same, if assignment name is the same then cover the original content
      exist_assi = Assignment.find(owner_id: auth[:account].id, assignment_name: assignment_data['assignment_name'])
      if exist_assi.nil?
        assi = auth[:account].add_owned_assignment(assignment_data)
        # Here only returns assignment metadata info
        Assignment.select(:id, :owner_id, :course_id, :assignment_name, :created_at, :updated_at).where(id: assi.id).first
      else
        assi = exist_assi.update(content: assignment_data['content'])
        # Here only returns assignment metadata info
        Assignment.select(:id, :owner_id, :course_id, :assignment_name, :created_at, :updated_at).where(id: assi.id).first
      end
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end

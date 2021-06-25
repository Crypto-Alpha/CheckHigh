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

    # check if assignment name is the same, if assignment name is the same then cover the original content
    def self.naming_assignment(auth, assignment_name)
      exist_assi = Assignment.find(owner_id: auth[:account].id, assignment_name: assignment_name)
      try_name = String.new(assignment_name)
      index_ = assignment_name[-4] == '.' ? -5 : -6
      name_num = 0
      while exist_assi
        name_num += 1
        try_name = String.new(assignment_name).insert(index_, "(#{name_num})")
        exist_assi = Assignment.find(owner_id: auth[:account].id, assignment_name: try_name)
      end
      try_name
    end

    def self.call(auth:, assignment_data:)
      raise ForbiddenError unless auth[:scope].can_write?('assignments')

      assignment_data['assignment_name'] = naming_assignment(auth, assignment_data['assignment_name'])

      assi = auth[:account].add_owned_assignment(assignment_data)
      # Here only returns assignment metadata info
      Assignment.select(:id, :owner_id, :course_id, :assignment_name, :created_at, :updated_at)
                .where(id: assi.id)
                .first
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end

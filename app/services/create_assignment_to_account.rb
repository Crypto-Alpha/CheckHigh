# frozen_string_literal: true

module CheckHigh
  # Create new assignment for an owner
  class CreateAssignmentForOwner
    def self.call(owner_id:, assignment_data:)
      Account.find(id: owner_id)
             .add_owned_assignment(assignment_data)
    end
  end
end

# frozen_string_literal: true

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

    def self.call(account:, assignment_data:)
      policy = AccountPolicy.new(account, account)
      raise ForbiddenError unless policy.can_edit?

      add_owned_assignment(account, assignment_data)
    end

    def self.add_owned_assignment(account, assignment_data)
      account.add_owned_assignment(assignment_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end

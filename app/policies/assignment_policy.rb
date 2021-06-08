# frozen_string_literal: true

module CheckHigh
  # Policy to determine if account can view a assignment
  class AssignmentPolicy
    def initialize(account, assignment)
      @account = account
      @assignment = assignment
    end

    def can_view?
      account_owns_assignment?
    end

    def can_edit?
      account_owns_assignment?
    end

    def can_delete?
      account_owns_assignment?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end

    private

    def account_owns_assignment?
      @assignment.owner_assignment_id == @account.id
    end
  end
end

# frozen_string_literal: true

module CheckHigh
  # Policy to determine if account can view a assignment
  class AssignmentPolicy
    def initialize(account, assignment)
      @account = account
      @assignment = assignment
    end

    # collaborator only can VIEW the other's assignment
    def can_view?
      account_owns_assignment? || account_collaborates_on_share_board?
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
      @assignment.owner_id == @account.id
    end

    def account_collaborates_on_share_board?
      @assignment.share_boards.each do |srb|
        return true if srb.collaborators.include?(@account)
      end
      false
    end
  end
end

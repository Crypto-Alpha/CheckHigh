# frozen_string_literal: true

module CheckHigh
  # Policy to determine if account can view a assignment
  class AssignmentPolicy
    def initialize(account, assignment, auth_scope = nil)
      @account = account
      @assignment = assignment
      @auth_scope = auth_scope
    end

    # collaborator only can VIEW the other's assignment
    def can_view?
      can_read? && (account_owns_assignment? || account_collaborates_on_share_board?)
    end

    def can_edit?
      can_write? && account_owns_assignment?
    end

    def can_delete?
      can_write? && account_owns_assignment?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('assignments') : false
    end
  
    def can_write?
      @auth_scope ? @auth_scope.can_write?('assignments') : false
    end

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

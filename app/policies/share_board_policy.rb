# frozen_string_literal: true

module CheckHigh
  # Policy to determine if an account can view a particular share_board
  class ShareBoardPolicy
    def initialize(account, share_board)
      @account = account
      @share_board = share_board
    end

    def can_view?
      account_is_owner? || account_is_collaborator?
    end

    # duplication is ok!
    def can_edit?
      account_is_owner? || account_is_collaborator?
    end

    def can_delete?
      account_is_owner?
    end

    def can_leave?
      account_is_collaborator?
    end

    def can_add_assignments?
      account_is_owner? || account_is_collaborator?
    end

    def can_remove_assignments?
      account_is_owner? || account_is_collaborator?
    end

    def can_add_collaborators?
      account_is_owner?
    end

    def can_remove_collaborators?
      account_is_owner?
    end

    def can_collaborate?
      not (account_is_owner? or account_is_collaborator?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_assignments: can_add_assignments?,
        can_delete_assignments: can_remove_assignments?,
        can_add_collaborators: can_add_collaborators?,
        can_remove_collaborators: can_remove_collaborators?,
        can_collaborate: can_collaborate?
      }
    end

    private

    def account_is_owner?
      @share_board.owner_share_board_id == @account.id
    end

    def account_is_collaborator?
      @share_board.collaborators.include?(@account)
    end
  end
end
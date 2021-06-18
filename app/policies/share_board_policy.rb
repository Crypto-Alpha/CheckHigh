# frozen_string_literal: true

module CheckHigh
  # Policy to determine if an account can view a particular share_board
  class ShareBoardPolicy
    def initialize(account, share_board, auth_scope = nil)
      @account = account
      @share_board = share_board
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_is_owner? || account_is_collaborator?)
    end

    # duplication is ok!
    def can_edit?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_leave?
      account_is_collaborator?
    end

    def can_add_assignments?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_remove_assignments?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_add_collaborators?
      can_write? && account_is_owner?
    end

    def can_remove_collaborators?
      can_write? && account_is_owner?
    end

    def can_collaborate?
      !(account_is_owner? || account_is_collaborator?)
    end

    def summary # rubocop:disable Metrics/MethodLength
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

    def can_read?
      @auth_scope ? @auth_scope.can_read?('share_boards') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('share_boards') : false
    end

    def account_is_owner?
      @share_board.owner_id == @account.id
    end

    def account_is_collaborator?
      @share_board.collaborators.include?(@account)
    end
  end
end

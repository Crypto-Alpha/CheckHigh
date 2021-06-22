# frozen_string_literal: true

module CheckHigh
  # Policy to determine if an account can view a particular share_board
  class CollaborationRequestPolicy
    def initialize(share_board, requestor_account, target_account, auth_scope = nil)
      @share_board = share_board
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = ShareBoardPolicy.new(requestor_account, share_board, auth_scope)
      @target = ShareBoardPolicy.new(target_account, share_board, auth_scope)
    end

    def can_invite?
      can_write? &&
        (@requestor.can_add_collaborators? && @target.can_collaborate?)
    end

    def can_remove?
      can_write? &&
        (@requestor.can_remove_collaborators? && target_is_collaborator?)
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('share_boards') : false
    end

    def target_is_collaborator?
      @share_board.collaborators.include?(@target_account)
    end
  end
end

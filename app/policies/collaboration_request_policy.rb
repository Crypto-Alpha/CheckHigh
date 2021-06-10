# frozen_string_literal: true

module CheckHigh
# Policy to determine if an account can view a particular share_board
  class CollaborationRequestPolicy
    def initialize(share_board, requestor_account, target_account)
      @share_board = share_board
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = ShareBoardPolicy.new(requestor_account, share_board)
      @target = ShareBoardPolicy.new(target_account, share_board)
    end

    def can_invite?
     @requestor.can_add_collaborators? && @target.can_collaborate?
    end

    def can_remove?
     @requestor.can_remove_collaborators? && target_is_collaborator?
    end

    private

    def target_is_collaborator?
     @share_board.collaborators.include?(@target_account)
    end
  end
end

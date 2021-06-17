# frozen_string_literal: true

module CheckHigh
  # Policy to determine if account can view a share_board
  class ShareBoardPolicy
    # Scope of share_board policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_share_boards(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |srb|
            includes_collaborator?(srb, @current_account)
          end
        end
      end

      private

      def all_share_boards(account)
        account.owned_share_boards + account.collaborations
      end

      def includes_collaborator?(share_board, account)
        share_board.collaborators.include? account
      end
    end
  end
end

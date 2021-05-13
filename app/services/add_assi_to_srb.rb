# frozen_string_literal: true

module CheckHigh
  # Create new assignments for a share board
  class CreateAssiForSrb
    def self.call(share_board_id:, assignment_data:)
      ShareBoard.first(id: share_board_id)
                .add_assignment(assignment_data)
    end
  end
end

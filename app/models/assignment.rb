# frozen_string_literal: true

require 'json'
require 'sequel'

module CheckHigh
  # Models a secret assignment
  class Assignment < Sequel::Model
    many_to_one :course
    many_to_many :share_boards,
                  class: :'CheckHigh::ShareBoard',
                  join_table: :share_boards_assignments,
                  left_key: :assignment_id, right_key: :share_board_id

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'assignment',
            attributes: {
              id: id,
              filename: assignment_name,
              content: content
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

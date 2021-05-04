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
    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :assignment_name, :content

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'assignment',
            attributes: {
              id: id,
              assignment_name: assignment_name,
              content: content
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

# frozen_string_literal: true

require 'json'
require 'sequel'

module CheckHigh
  # Models a section
  class ShareBoard < Sequel::Model
    many_to_many :assignments,
                  class: :'CheckHigh::Assignment',
                  join_table: :share_boards_assignments,
                  left_key: :share_board_id, right_key: :assignment_id

    many_to_many :dashboards,
                  class: :'CheckHigh::Dashboard',
                  join_table: :dashboards_share_boards,
                  left_key: :share_board_id, right_key: :dashboard_id

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :share_board_name


    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'share_board',
            attributes: {
              id: id,
              share_board_name: share_board_name
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

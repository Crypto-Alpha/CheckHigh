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
                 sleft_key: :share_board_id, right_key: :dashboard_id

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :share_board_name

    # rubocop:disable Metrics/MethodLength
    def simplify_to_json(options = {})
      # for only showing course id & name
      JSON(
        {
          data: {
            type: 'share_board',
            attributes: {
              id: id,
              share_board_name: share_board_name,
              links: {
                rel: 'share_board_details',
                # this link relates to share_board details
                href: "#{Api.config.API_HOST}/api/v1/share_boards/#{id}"
              }
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'share_board',
            attributes: {
              id: id,
              share_board_name: share_board_name,
              links: {
                rel: 'assignment_details',
                # this should show assignments(only id & name) related to this share_board
                href: "#{Api.config.API_HOST}/api/v1/share_boards/#{id}/assignments"
              }
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

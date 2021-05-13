# frozen_string_literal: true

require 'json'
require 'sequel'

module CheckHigh
  # Models a section
  class ShareBoard < Sequel::Model
    many_to_one :owner, class: :'CheckHigh::Account'

    many_to_many :collaborators,
                 class: :'CheckHigh::Account',
                 join_table: :accounts_share_boards,
                 left_key: :share_board_id, right_key: :collaborator_id

    many_to_many :assignments,
                 class: :'CheckHigh::Assignment',
                 join_table: :assignments_share_boards,
                 left_key: :share_board_id, right_key: :assignment_id

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :share_board_name

    plugin :association_dependencies,
    assignments: :nullify,
    collaborators: :nullify

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

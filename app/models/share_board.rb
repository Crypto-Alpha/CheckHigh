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
    def to_h
      {
        type: 'share_board',
        attributes: {
          id: id,
          share_board_name: share_board_name,
          links: {
            rel: 'assignment_details',
            href: "#{Api.config.API_HOST}/api/v1/share_boards/#{id}/assignments"
          }
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    def full_details
      to_h.merge(
        relationships: {
          owner: owner,
          collaborators: collaborators,
          assignments: assignments
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end

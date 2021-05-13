# frozen_string_literal: true

require 'json'
require 'sequel'

module CheckHigh
  # Models a section
  class ShareBoard < Sequel::Model
    many_to_one :owner, class: :'CheckHigh::Account'

    many_to_many :collaborators,
                 class: :'CheckHigh::Account',
                 join_table: :accounts_shareboards,
                 left_key: :shareboard_id, right_key: :collaborator_id

    many_to_many :assignments,
                 class: :'CheckHigh::Assignment',
                 join_table: :assignments_shareboards,
                 left_key: :shareboard_id, right_key: :assignment_id

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :shareboard_name

    plugin :association_dependencies,
    assignments: :nullify,
    collaborators: :nullify

    # rubocop:disable Metrics/MethodLength
    def simplify_to_json(options = {})
      # for only showing course id & name
      JSON(
        {
          data: {
            type: 'shareboard',
            attributes: {
              id: id,
              shareboard_name: shareboard_name,
              links: {
                rel: 'shareboard_details',
                # this link relates to shareboard details
                href: "#{Api.config.API_HOST}/api/v1/shareboards/#{id}"
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
            type: 'shareboard',
            attributes: {
              id: id,
              shareboard_name: shareboard_name,
              links: {
                rel: 'assignment_details',
                # this should show assignments(only id & name) related to this shareboard
                href: "#{Api.config.API_HOST}/api/v1/shareboards/#{id}/assignments"
              }
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

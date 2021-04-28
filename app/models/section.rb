# frozen_string_literal: true

require 'json'
require 'sequel'

module CheckHigh
  # Models a section
  class Section < Sequel::Model
    many_to_many :assignments,
                  class: :'CheckHigh::Assignment',
                  join_table: :section_assignment,
                  left_key: :section_id, right_key: :assignment_id

    many_to_many :dashboards,
                  class: :'CheckHigh::Dashboard',
                  join_table: :section_dashboard,
                  left_key: :section_id, right_key: :dashboard_id

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'section',
            attributes: {
              id: id,
              name: names
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

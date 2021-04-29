# frozen_string_literal: true

require 'json'
require 'sequel'

module CheckHigh
  # Models a dashboard
  class Dashboard < Sequel::Model
    one_to_many :courses
    many_to_many :sections,
                  class: :'CheckHigh::Section',
                  join_table: :dashboards_sections,
                  left_key: :dashboard_id, right_key: :section_id

    plugin :association_dependencies, courses: :destroy
    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'dashboard',
            attributes: {
              id: id,
              name: name,
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

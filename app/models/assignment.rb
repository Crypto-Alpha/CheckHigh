# frozen_string_literal: true

require 'json'
require 'sequel'

module CheckHigh
  # Models a secret assignment
  class Assignment < Sequel::Model
    many_to_one :course
    many_to_many :sections,
                  class: :'CheckHigh::Section',
                  join_table: :sections_assignments,
                  left_key: :assignment_id, right_key: :section_id

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'assignment',
            attributes: {
              id: id,
              filename: filename,
              content: content
            }
          },
          included: {
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

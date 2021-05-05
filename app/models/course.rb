# frozen_string_literal: true

require 'json'
require 'sequel'

module CheckHigh
  # Models a secret assignment
  class Course < Sequel::Model
    many_to_one :dashboard
    one_to_many :assignments

    plugin :association_dependencies, assignments: :destroy
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :dashboard_name

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'course',
            attributes: {
              id: id,
              course_name: course_name
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

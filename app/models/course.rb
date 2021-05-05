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
    set_allowed_columns :course_name

    # rubocop:disable Metrics/MethodLength
    def simplify_to_json(options = {})
      # for only showing course id & name 
      JSON(
        {
          data: {
            type: 'course',
            attributes: {
              id: id,
              course_name: course_name,
              links: {
                rel: 'course_details',
                # this link relates to course details 
                href: "#{Api.config.API_HOST}/api/v1/courses/#{id}"
              }
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      # for showing course details & related assignment link or creating related
      JSON(
        {
          data: {
            type: 'course',
            attributes: {
              id: id,
              course_name: course_name,
              links: {
                rel: 'assignment_details',
                # this should show assignments(only id & name) related to this course
                href: "#{Api.config.API_HOST}/api/v1/courses/#{id}/assignments"
              }
            },
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

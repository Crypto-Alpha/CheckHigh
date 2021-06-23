# frozen_string_literal: true

require 'json'
require 'sequel'

module CheckHigh
  # Models a secret assignment
  class Course < Sequel::Model
    many_to_one :owner, class: :'CheckHigh::Account'

    one_to_many :assignments

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :course_name

    plugin :association_dependencies,
           assignments: :destroy

    # rubocop:disable Metrics/MethodLength
    def to_h
      {
        type: 'course',
        attributes: {
          id: id,
          course_name: course_name,
          links: {
            rel: 'assignment_details',
            # this should show assignments(only id & name) related to this course
            href: "#{Api.config.API_HOST}/api/v1/courses/#{id}/assignments"
          }
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    def full_details
      to_h.merge(
        relationships: {
          owner: owner,
          assignments: get_assignments(id)
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
    
    private

    def get_assignments(course_id)
      assis = Course.find(id: course_id).assignments
      if assis.count != 0
        assis.sort_by(&:created_at).map do |assignment|
          ParseAssignmentData.get_metadata_from_db(assignment)
        end
      else [] end
    end
  end
end

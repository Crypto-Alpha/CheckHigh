# frozen_string_literal: true

module CheckHigh
  # Add a collaborator to another owner's existing course
  class GetCourseQuery
    # Error for owner cannot access
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that course'
      end
    end

    # Error for cannot find a course
    class NotFoundError < StandardError
      def message
        'We could not find that course'
      end
    end

    def self.call(auth:, course:)

      raise NotFoundError unless course

      policy = CoursePolicy.new(auth[:account], course, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      course.full_details.merge(policies: policy.summary)
    end
  end
end

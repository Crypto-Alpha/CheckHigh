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

    def self.call(account:, course:)

      raise NotFoundError unless course

      policy = CoursePolicy.new(account, course)
      raise ForbiddenError unless policy.can_view?

      course
    end
  end
end

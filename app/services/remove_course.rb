# frozen_string_literal: true

module CheckHigh
  # Remove an course
  class RemoveCourse
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that course'
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
      raise ForbiddenError unless policy.can_delete?

      # real delete
      course.destroy
    end
  end
end

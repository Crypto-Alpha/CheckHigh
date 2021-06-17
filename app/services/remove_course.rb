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

      course.remove_all_assignments
      auth[:account].remove_owned_course(course)

      #TODO: course cannot be removed (sqlite foreign constraints) (wait for solutions)
      #deleted_course = course.delete
      #deleted_course
    end
  end
end

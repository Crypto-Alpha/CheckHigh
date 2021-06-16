# frozen_string_literal: true

module CheckHigh
  # Rename course's name 
  class RenameCourse
    # Error for access that course 
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

    # Share board for given requestor account
    def self.call(auth:, course:, new_name:)
      raise NotFoundError unless course

      policy = CoursePolicy.new(auth[:account], course, auth[:scope])
      raise ForbiddenError unless policy.can_edit?

      course.update(course_name: new_name)
    end
  end
end

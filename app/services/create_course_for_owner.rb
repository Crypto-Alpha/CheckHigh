# frozen_string_literal: true
require_relative '../policies/account_policy'

# TODO: not sure the logic is right or not.
module CheckHigh
  # Create new course for an owner
  class CreateCourseForOwner
    # Error for owner cannot create course
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more courses'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a course with those attributes'
      end
    end

    def self.call(auth:, course_data:)
      raise ForbiddenError unless auth[:scope].can_write?('courses')

      auth[:account].add_owned_course(course_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end

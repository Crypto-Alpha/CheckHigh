# frozen_string_literal: true

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

    def self.call(account:, course_data:)
      policy = AccountPolicy.new(account, account)
      raise ForbiddenError unless policy.can_edit?

      add_owned_course(account, course_data)
    end

    def self.add_owned_course(account, course_data)
      account.add_owned_course(course_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end

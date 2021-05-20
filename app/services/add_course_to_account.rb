# frozen_string_literal: true

module CheckHigh
  # Create new course for an account
  class CreateCourseForAccount
    def self.call(account_id:, course_data:)
      Account.find(id: account_id)
             .add_owned_course(course_data)
    end
  end
end

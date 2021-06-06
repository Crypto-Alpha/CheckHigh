# frozen_string_literal: true

module CheckHigh
  # Create new course for an owner
  class CreateCourseForOwner
    def self.call(owner_id:, course_data:)
      Account.find(id: owner_id)
             .add_owned_course(course_data)
    end
  end
end

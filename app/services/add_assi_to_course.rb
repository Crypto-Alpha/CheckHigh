# frozen_string_literal: true

module CheckHigh
  # Create new assignments for a share board
  class CreateAssiForCourse
    def self.call(course_id:, assignment_data:)
      Course.first(id: course_id)
            .add_assignment(assignment_data)
    end
  end
end

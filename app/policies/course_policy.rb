# frozen_string_literal: true

module CheckHigh
  # Policy to determine if an account can view a particular course
  class CoursePolicy
    def initialize(account, course)
      @account = account
      @course = course
    end

    def can_view?
      account_is_owner?
    end

    def can_edit?
      account_is_owner?
    end

    def can_delete?
      account_is_owner?
    end

    def can_add_assignments?
      account_is_owner?
    end

    def can_remove_assignments?
      account_is_owner?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_add_assignments: can_add_assignments?,
        can_delete_assignments: can_remove_assignments?
      }
    end

    private

    def account_is_owner?
      @course.owner_course_id == @account.id
    end
  end
end

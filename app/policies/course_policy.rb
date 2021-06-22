# frozen_string_literal: true

module CheckHigh
  # Policy to determine if an account can view a particular course
  class CoursePolicy
    def initialize(account, course, auth_scope = nil)
      @account = account
      @course = course
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && account_is_owner?
    end

    def can_edit?
      can_write? && account_is_owner?
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_add_assignments?
      can_write? && account_is_owner?
    end

    def can_remove_assignments?
      can_write? && account_is_owner?
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

    def can_read?
      @auth_scope ? @auth_scope.can_read?('courses') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('courses') : false
    end

    def account_is_owner?
      @course.owner_id == @account.id
    end
  end
end

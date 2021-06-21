# frozen_string_literal: true

module CheckHigh
  # Policy to determine if account can view a course
  class CoursePolicy
    # Scope of course policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_courses(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        @full_scope if @current_account == @target_account
      end

      private

      def all_courses(account)
        account.owned_courses
      end

      def all_assignments(course)
        course.assignments
      end
    end
  end
end

# frozen_string_literal: true

module CheckHigh
  # Policy to determine if account can view a assignment
  class AssignmentPolicy
    # Scope of assignment policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_lonely_assignments(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        @full_scope if @current_account == @target_account
      end

      private

      def all_lonely_assignments(account)
        Assignment.select(:id, :owner_id, :course_id, :assignment_name, :created_at, :updated_at)
          .where(owner_id: account.id, course_id: nil).order(Sequel.asc(:created_at)).all
      end
    end

    # Scope of course policies
    class CourseScope
      def initialize(current_course, target_course = nil)
        target_course ||= current_course
        @full_scope = all_assignments(target_course)
        @current_course = current_course
        @target_course = target_course
      end

      def viewable
        @full_scope if @current_course == @target_course
      end

      private

      def all_assignments(course)
        assis = course.assignments
        if assis.count != 0
          assis.sort_by(&:created_at).map do |assignment|
            ParseAssignmentData.get_metadata(assignment)
          end
        else [] end
      end
    end

    # Scope of share_board policies
    class ShareBoardScope
      def initialize(current_share_board, target_share_board = nil)
        target_share_board ||= current_share_board
        @full_scope = all_assignments(target_share_board)
        @current_share_board = current_share_board
        @target_share_board = target_share_board
      end

      def viewable
        @full_scope if @current_share_board == @target_share_board
      end

      private

      def all_assignments(share_board)
        assis = share_board.assignments
        if assis.count != 0
          assis.sort_by(&:created_at).map do |assignment|
            ParseAssignmentData.get_metadata_from_db(assignment)
          end
        else [] end
      end
    end
  end
end

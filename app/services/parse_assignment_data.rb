# frozen_string_literal: true

require_relative 'remove_course'

module CheckHigh
  # Parse an assignment 
  class ParseAssignmentData

    def self.call(headers, body)
      {
        'assignment_name' => headers[:assignment_name],
        'content' => body
      }
    end

    def self.get_metadata_from_db(assignment)
      Assignment.select(:id, :owner_id, :course_id, :assignment_name, :created_at, :updated_at)
        .where(id: assignment.id).first
    end

    def self.get_metadata(assignment)
      assignment[:attributes].delete(:content)
      assignment
    end

    def self.get_content(assignment)
      assignment[:attributes][:content]
    end
  end
end

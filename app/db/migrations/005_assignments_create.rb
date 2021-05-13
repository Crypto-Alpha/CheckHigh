# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:assignments) do
      uuid :id, primary_key: true
      foreign_key :course_id, table: :courses
      foreign_key :owner_assignment_id, table: :accounts

      String :assignment_name_secure, null: false, default: ''
      String :content_secure, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at

      unique %I[owner_assignment_id assignment_name_secure]
    end
  end
end

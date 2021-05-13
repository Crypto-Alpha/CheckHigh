# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:courses) do
      primary_key :id
      foreign_key :owner_course_id, :accounts

      String :course_name, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at

      unique %I[owner_course_id course_name]
    end
  end
end

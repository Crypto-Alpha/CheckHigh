# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:assignments) do
      primary_key :id
      foreign_key :course_id, table: :courses

      String :name, null: false, default: ''
      String :content, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at

      unique %I[course_id name]
    end
  end
end

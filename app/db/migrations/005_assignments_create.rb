# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:assignments) do
      uuid :id, primary_key: true
      foreign_key :owner_id, table: :accounts
      foreign_key :course_id, table: :courses

      String :assignment_name, null: false, default: ''
      String :content_secure, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at

      unique %I[owner_id assignment_name]
    end
  end
end

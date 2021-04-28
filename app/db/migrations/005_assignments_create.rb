# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:assignments) do
      primary_key :id
      foreign_key :folder_id, table: :folders

      String :name, unique: true, null: false
      String :content, unique: true, null: false

      DateTime :created_at
      DateTime :updated_at

      unique %I[folder_id name]
    end
  end
end

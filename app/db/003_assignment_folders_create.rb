# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:assignment_folders) do
      primary_key :id
      foreign_key :section_id, table: :sections

      String :name, unique: true, null: false

      DateTime :created_at
      DateTime :updated_at

      unique [:section_id, :name]
    end
  end
end
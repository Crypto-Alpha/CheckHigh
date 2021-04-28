# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:folders) do
      primary_key :id
      foreign_key :dashboard_id, table: :dashboards

      String :name, unique: true, null: false

      DateTime :created_at
      DateTime :updated_at

      unique %I[dashboard_id name]
    end
  end
end

# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:shareboards) do
      primary_key :id
      foreign_key :owner_shareboard_id, :accounts

      String :shareboard_name, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at

      unique %I[owner_shareboard_id shareboard_name]
    end
  end
end

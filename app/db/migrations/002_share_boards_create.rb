# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:share_boards) do
      primary_key :id
      foreign_key :owner_id, :accounts

      String :share_board_name, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at

      unique %I[owner_id share_board_name]
    end
  end
end

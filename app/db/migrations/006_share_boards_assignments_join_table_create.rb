# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:share_boards_assignments) do
      primary_key %I[share_board_id assignment_id]
      foreign_key :share_board_id, table: :share_boards
      foreign_key :assignment_id, table: :assignments

      index %I[share_board_id assignment_id]
    end
  end
end

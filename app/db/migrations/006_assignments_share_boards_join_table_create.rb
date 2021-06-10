# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(assignment_id: { table: :assignments, type: :uuid }, share_board_id: :share_boards)
  end
end

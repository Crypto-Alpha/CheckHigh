# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:dashboards_share_boards) do
      primary_key %I[dashboard_id section_id]
      foreign_key :dashboard_id, table: :dashboards
      foreign_key :share_board_id, table: :share_boards

      index %I[dashboard_id share_board_id]
    end
  end
end

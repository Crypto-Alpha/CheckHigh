# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:dashboards_sections) do
      primary_key %I[dashboard_id section_id]
      foreign_key :dashboard_id, table: :dashboards
      foreign_key :section_id, table: :sections

      index %I[dashboard_id section_id]
    end
  end
end

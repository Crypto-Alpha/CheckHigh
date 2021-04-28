# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:sections_assignments) do
      primary_key %I[section_id assignment_id]
      foreign_key :section_id, table: :sections
      foreign_key :assignment_id, table: :assignments

      index %I[section_id assignment_id]
    end
  end
end

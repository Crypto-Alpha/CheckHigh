# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(assignment_id: :assignments, shareboard_id: :shareboards)
  end
end

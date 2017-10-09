# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :permissions do
      primary_key :id
      String :verb
      String :pattern
      DateTime :created_at
      foreign_key :role_id, :roles
    end
  end
end

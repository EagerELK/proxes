# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :permissions do
      add_foreign_key :user_id, :users
    end
  end
end

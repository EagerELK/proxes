# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :permissions do
      add_column :index, String, default: '*', null: false
    end
  end
end

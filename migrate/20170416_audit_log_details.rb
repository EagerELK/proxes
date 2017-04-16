# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :audit_logs do
      add_column :details, String, text: true
    end
  end
end

# frozen_string_literal: true
Sequel.migration do
  change do
    create_table :audit_logs do
      primary_key :id
      foreign_key :user_id, :users, null: true
      String :action
      DateTime :created_at
    end
  end
end

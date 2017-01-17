# frozen_string_literal: true
Sequel.migration do
  change do
    create_table :audit_logs do
      primary_key :id
      String :action
      DateTime :created_at
    end
  end
end

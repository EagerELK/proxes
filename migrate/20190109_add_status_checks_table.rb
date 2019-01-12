# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :status_checks do
      primary_key :id
      String :type, nullable: false
      String :name, nullable: false
      String :source, nullable: false
      String :required_value, nullable: true, default: nil
      Integer :order, nullable: false, default: 1
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      unique [:name]
    end
  end
end

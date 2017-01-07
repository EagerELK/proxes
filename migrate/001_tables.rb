# frozen_string_literal: true
Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :name
      String :surname
      String :email
      DateTime :created_at
      DateTime :updated_at
      unique [:email]
    end

    create_table :identities do
      primary_key :id
      foreign_key :user_id, :users
      String :username
      String :crypted_password
      DateTime :created_at
      DateTime :updated_at
      unique [:username]
    end

    create_table :roles do
      primary_key :id
      String :name
      DateTime :created_at
      DateTime :updated_at
      unique [:name]
    end

    create_table :permissions do
      primary_key :id
      String :verb
      String :pattern
      DateTime :created_at
      foreign_key :role_id, :roles
    end

    create_table :roles_users do
      DateTime :created_at
      foreign_key :user_id, :users
      foreign_key :role_id, :roles
      unique [:user_id, :role_id]
    end
  end
end

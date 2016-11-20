Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :name
      String :surname
      String :email
      DateTime :created_at
      DateTime :updated_at
    end

    create_table :identities do
      primary_key :id
      foreign_key :user_id, :users
      String :username
      String :crypted_password
      DateTime :created_at
      DateTime :updated_at
    end

    create_table :user_roles do
      primary_key :id
      foreign_key :user_id, :users
      String :role
      unique [:user_id, :role]
    end
  end
end

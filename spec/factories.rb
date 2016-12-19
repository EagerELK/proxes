require 'proxes/models/user'
require 'proxes/models/user_role'

FactoryGirl.define do
  to_create { |i| i.save }

  sequence(:email) { |n| "person-#{n}@example.com" }
  sequence(:name) { |n| "Name-#{n}" }

  factory :user, class: ProxES::User, aliases: [:'ProxES::User'] do
    email
    after(:create) do |user, evaluator|
      user.add_user_role(role: 'user')
    end

    factory :admin_user do
      after(:create) do |user, evaluator|
        user.add_user_role(role: 'admin')
      end
    end

    factory :super_admin_user do
      after(:create) do |user, evaluator|
        user.add_user_role(role: 'super_admin')
      end
    end
  end

  factory :user_role, class: ProxES::UserRole, aliases: [:'ProxES::UserRole'] do
    role
    user
  end
end

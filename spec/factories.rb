# frozen_string_literal: true
require 'ditty/components/app/models/user'
require 'ditty/components/app/identity'
require 'ditty/components/app/role'

FactoryGirl.define do
  to_create(&:save)

  sequence(:email) { |n| "person-#{n}@example.com" }
  sequence(:name) { |n| "Name-#{n}" }

  factory :user, class: ProxES::User, aliases: [:'ProxES::User'] do
    email

    after(:create) do |user, _evaluator|
      create(:identity, user: user)
    end

    factory :super_admin_user do
      after(:create) do |user, _evaluator|
        user.add_role(Ditty::Role.find_or_create(name: 'super_admin'))
      end
    end
  end

  factory :identity, class: Ditty::Identity, aliases: [:'Ditty::Identity'] do
    username { generate :email }
    crypted_password 'som3Password!'
  end

  factory :role, class: Ditty::Role, aliases: [:'Ditty::Role'] do
    name { "Role #{generate(:name)}" }
  end

  factory :permission, class: ProxES::Permission, aliases: [:'ProxES::Permission'] do
    pattern '*'
    verb 'GET'
    role
  end
end

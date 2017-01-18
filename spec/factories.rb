# frozen_string_literal: true
require 'proxes/models/user'
require 'proxes/models/identity'
require 'proxes/models/role'

FactoryGirl.define do
  to_create(&:save)

  sequence(:email) { |n| "person-#{n}@example.com" }
  sequence(:name) { |n| "Name-#{n}" }

  factory :user, class: ProxES::User, aliases: [:'ProxES::User'] do
    email

    factory :super_admin_user do
      after(:create) do |user, _evaluator|
        user.add_role(ProxES::Role.find_or_create(name: 'super_admin'))
      end
    end
  end

  factory :identity, class: ProxES::Identity, aliases: [:'ProxES::Identity'] do
    username { generate :email }
    crypted_password 'som3Password!'
  end

  factory :role, class: ProxES::Role, aliases: [:'ProxES::Role'] do
    name 'test'
  end

  factory :permission, class: ProxES::Permission, aliases: [:'ProxES::Permission'] do
    pattern '*'
    verb 'GET'
    role
  end
end

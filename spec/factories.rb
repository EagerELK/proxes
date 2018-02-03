# frozen_string_literal: true

require 'ditty/models/user'
require 'ditty/models/role'
require 'ditty/models/identity'
require 'proxes/models/permission'

FactoryBot.define do
  to_create(&:save)

  sequence(:email) { |n| "person-#{n}@example.com" }
  sequence(:name) { |n| "Name-#{n}" }

  factory :user, class: Ditty::User, aliases: [:'Ditty::User'] do
    email

    after(:create) do |user, _evaluator|
      create(:identity, user: user)
    end

    factory :super_admin_user do
      after(:create) do |user, _evaluator|
        user.add_role(Ditty::Role.find_or_create(name: 'super_admin'))
        ProxES::Permission.find_or_create(user: user, verb: 'GET', pattern: '/')
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

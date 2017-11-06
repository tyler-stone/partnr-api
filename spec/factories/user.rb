FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    first_name "John"
    last_name  "Doe"
    email
    password "example_password"
  end

  factory :user2, class: User do
    first_name "Bob"
    last_name "Jones"
    email
    password "example_password"
  end

  factory :user3, class: User do
    first_name "Sean"
    last_name "TheTester"
    email
    password "example_password"
  end
end

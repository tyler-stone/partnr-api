FactoryGirl.define do
  factory :role do
    title "Project Manager"
    project nil
  end

  factory :role2, class: Role do
    title "Software Engineer"
    project nil
  end

end

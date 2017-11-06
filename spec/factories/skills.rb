FactoryGirl.define do
  factory :skill do
    title "Shearing"
  end

  factory :skill2, class: Skill do
    title "Sewing"
  end
end

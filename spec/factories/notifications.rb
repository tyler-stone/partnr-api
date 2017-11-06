FactoryGirl.define do
  factory :notification do
    factory :created do
      action 0
    end

    factory :updated do
      action 1
    end

    factory :destroyed do
      action 2
    end
  end

end

FactoryGirl.define do
  factory :project do
    factory :good_project do
      type "HobbyProject"
      title "A great project!"
      owner 1
      creator 1
      status 0
    end

    factory :good_project2 do
      type "HobbyProject"
      title "A fine project"
      owner 2
      creator 2
      status 0
    end

    factory :invalid_project do
      type "HobbyProject"
      title "A not so great project"
      owner nil
      creator nil
      status 0
    end

    factory :school_project do
      type "SchoolProject"
      title "Project for school"
      owner 2
      creator 2
      status 0
    end

    factory :work_project do
      type "WorkProject"
      title "Work thing I want to do"
      owner 2
      creator 2
      status 0
      sponsor "Pawtucket Brewery"
    end

    factory :paid_project do
      type "PaidProject"
      title "Project for money"
      owner 2
      creator 2
      status 0
      payment_price 29.29
    end

    factory :hobby_project do
      type "HobbyProject"
      title "Project as a hobby"
      owner 2
      creator 2
      status 0
    end

  end
end

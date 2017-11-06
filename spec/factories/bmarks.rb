FactoryGirl.define do
  factory :bmark do
    title "MyString"
  end

  factory :bmark2, class: Bmark do
    title "Second Benchmark"
  end

  factory :bmark3, class: Bmark do
    title "Third Benchmark"
  end

  factory :bmark4, class: Bmark do
    title "Fourth Benchmark"
  end
end

FactoryGirl.define do
  factory :pagematch do
    page_id 1
    match_id 1
  end
  factory :page do
    ref "MyString"
  end
end 
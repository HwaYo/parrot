FactoryGirl.define do
  factory :record do
    title "test record"
    note "test note"
  end

  factory :user do
    provider "facebook"
    uid "1234512345"
    name "John"
    image ""
    email "john@hwayo.com"
  end

  factory :bookmark do
    color "#C0FFEE"
    name "Important"
    user
  end
end
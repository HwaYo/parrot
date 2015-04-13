FactoryGirl.define do
  factory :record do
    title "test record"
    note <<-str
      test note
      <a class="bookmark-tag" href="#" contenteditable="false" data-start="1" data-end="2">0.5초 - 1</a>
    str
    bookmark JSON.generate([{ start: 0.5, end: 1.5, data: 1 }])
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
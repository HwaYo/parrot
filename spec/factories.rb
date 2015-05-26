FactoryGirl.define do  factory :subscription do
    
  end

  factory :user do
    provider "facebook"
    uid "1234512345"
    name "John"
    image ""
    email "john@hwayo.com"
  end

  factory :record do
    title "test record"
    note <<-str
      test note
      <a class="bookmark-tag" href="#" contenteditable="false" data-start="1" data-end="2">0.5초 - 1</a>
    str
    bookmark JSON.generate([{ start: 0.5, end: 1.5, name: "Important", color: "#c0ffee" }])
    user
    file Rack::Test::UploadedFile.new(Rails.root.join('spec/files/blob.wav'), "audio/wav")
  end

  factory :bookmark do
    color "#C0FFEE"
    name "Important"
    user
  end

  factory :bookmark_history do
    record
    bookmark
    start 0
    send('end', 1)
  end
end
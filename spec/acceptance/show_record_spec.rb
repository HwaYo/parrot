require 'rails_helper'

RSpec.describe 'Record play process', type: :feature do
  before :each do
    @uploaded = Rack::Test::UploadedFile.new(Rails.root.join('spec/files/blob.wav'), "audio/wav")
    @record = FactoryGirl.create(:record, file: @uploaded)
    sign_in!
    visit record_path(@record)
  end

  it "plays a recorded voice" do
    selenium_required!

    all('[data-play]').first.click

    expect(page).to have_selector('[data-play]', visible: false)
    expect(page).to have_selector('[data-pause]', visible: true)
  end

  it "shows a written note" do
    note_area = find('#note-area')
    expect(note_area).to have_content('test note')
  end

  it "plays record faster or slower by 0.1x" do
    selenium_required!

    speed_info = find('#speed-info')

    find('#speed-up-btn').click
    expect(speed_info).to have_content('1.1')

    find('#speed-down-btn').click
    expect(speed_info).to have_content('1.0')
  end

  it "plays record by clicking control panel button" do
    selenium_required!

    find('.play-controller [data-action=play]').click
    expect(page).to have_selector('[data-play]', visible: false)
    expect(page).to have_selector('[data-pause]', visible: true)
  end

  it "plays record from start of the note bookmark" do
    selenium_required!

    bookmark = JSON.parse(@record.bookmark).first

    all('.bookmark-tag')[0].click
    current_time = page.evaluate_script <<-script
      document.getElementsByTagName('audio')[0].currentTime
    script

    expect(current_time).to be > bookmark["start"]
  end

  it "plays record from start of the playbar bookmark" do
    selenium_required!

    bookmark = JSON.parse(@record.bookmark).first

    all('.wavesurfer-region')[0].click
    current_time = page.evaluate_script <<-script
      document.getElementsByTagName('audio')[0].currentTime
    script

    expect(current_time).to be > bookmark["start"]
  end
end
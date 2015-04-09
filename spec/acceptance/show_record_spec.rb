require 'rails_helper'

RSpec.describe 'Record play process', type: :feature do
  before :each do
    @record = FactoryGirl.create(:record)

    sign_in!
    visit record_path(@record)
  end

  it "plays a recorded voice", js: true do
    find('#play').click

    expect(page).to have_selector('#play', visible: false)
    expect(page).to have_selector('#pause', visible: true)
  end

  it "shows a written note" do
    note_area = find('#note-area')
    expect(note_area).to have_content('test note')
  end

  it "shows bookmarks" do
    skip "See https://github.com/HwaYo/parrot/issues/37"
  end
end
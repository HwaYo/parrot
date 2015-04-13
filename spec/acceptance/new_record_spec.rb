require 'rails_helper'

RSpec.describe 'Record creation process', type: :feature do
  def start_record!
    find('.recorder-component.record').click
  end

  def pause_record!
    find('.recorder-component.pause').click
  end

  def save_record!
    find('.recorder-component.save').click
  end

  it 'shows a new record page' do
    sign_in!
    find('#menu-toggle').click
    click_link 'New Record'
    expect(current_path).to eq(new_record_path)
  end

  context 'when user is in new record page' do
    before :each do
      FactoryGirl.create :bookmark

      sign_in!
      visit new_record_path
    end

    # requires "always permit" for microphone sharing @ about:permissions
    it "records audio" do
      selenium_required!

      start_record!

      # http://stackoverflow.com/questions/8801845/how-to-make-capybara-check-for-visibility-after-some-js-has-run
      expect(page).to have_selector('.recorder-component.record', visible: false)
      expect(page).to have_selector('.recorder-component.pause', visible: true)

      pause_record!
      expect(page).to have_selector('.recorder-component.save', visible: true)

      save_record!

      sleep 3

      record = Record.last
      expect(current_path).to eq(record_path(record))
    end

    it "creates a bookmark" do
      selenium_required!

      start_record!

      find('[data-bookmark]').click
      expect(page).to have_selector('.bookmark-tag')

      pause_record!
      save_record!

      expect(page).to have_selector('.bookmark-tag')
    end

    it "allow write a note" do
      selenium_required!

      start_record!

      note_area = find('#note-area')
      note_area.set('Hello, World!')

      pause_record!
      save_record!

      expect(page).to have_content('Hello, World!')
    end
  end
end
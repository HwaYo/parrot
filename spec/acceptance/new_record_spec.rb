require 'rails_helper'

RSpec.describe 'Record creation process', type: :feature do
  it 'shows a new record page' do
    sign_in!
    find('#menu-toggle').click
    click_link '새 녹음본 만들기'
    expect(current_path).to eq(new_record_path)
  end

  context 'when user is in new record page' do
    before :each do
      sign_in!
      visit new_record_path
    end

    # requires "always permit" for microphone sharing @ about:permissions
    it "records audio" do
      selenium_required!

      find('.recorder-component.record').click

      # http://stackoverflow.com/questions/8801845/how-to-make-capybara-check-for-visibility-after-some-js-has-run
      expect(page).to have_selector('.recorder-component.record', visible: false)
      expect(page).to have_selector('.recorder-component.pause', visible: true)

      find('.recorder-component.pause').click

      expect(page).to have_selector('.recorder-component.save', visible: true)
      find('.recorder-component.save').click

      sleep 3

      record = Record.last
      expect(current_path).to eq(record_path(record))
    end
  end
end
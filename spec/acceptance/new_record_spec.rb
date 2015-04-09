require 'rails_helper'

RSpec.describe 'Record creation process', type: :feature do
  def sign_in!
    visit "/"
    click_link "페이스북으로 시작하기"
  end

  def move_to_new_record_page!
    sign_in!
    find('#menu-toggle').click
    click_link '새 녹음본 만들기'
  end

  it 'shows a new record page' do
    move_to_new_record_page!
    expect(current_path).to eq(new_record_path)
  end

  context 'when user is in new record page' do
    before :each do
      move_to_new_record_page!
    end

    # requires "always permit" for microphone sharing @ about:permissions
    it "records audio", js: true do
      skip
      find('.recorder-component.record').click

      # http://stackoverflow.com/questions/8801845/how-to-make-capybara-check-for-visibility-after-some-js-has-run
      expect(page).to have_selector('.recorder-component.record', visible: false)
      expect(page).to have_selector('.recorder-component.pause', visible: true)

      find('.recorder-component.pause').click

      expect(page).to have_selector('.recorder-component.save', visible: true)
      find('.recorder-component.save').click

      sleep 10

      record = Record.last
      expect(current_path).to eq(record_path(record))
    end
  end
end
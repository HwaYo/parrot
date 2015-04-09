require 'rails_helper'

RSpec.describe 'Record management process', type: :feature do
  def sign_in!
    visit "/"
    click_link "페이스북으로 시작하기"
  end

  before :each do
    @record = FactoryGirl.create(:record)
    sign_in!
  end

  it 'shows records' do
    expect(page).to have_content('test record')
  end

  it 'allows delete a record', js: true do
    find('[data-method=delete]').click
    page.driver.browser.switch_to.alert.accept

    expect(page).not_to have_selector('.record-item-container')
  end

  it "allows modify a record title", js: true do
    skip "See https://github.com/HwaYo/parrot/issues/61"
    find('[data-target=#edit-modal]').click
  end
end
require 'rails_helper'

RSpec.describe 'Record management process', type: :feature do
  before :each do
    @record = FactoryGirl.create(:record)
    sign_in!
  end

  it 'shows records' do
    expect(page).to have_content('test record')
  end

  it 'allows delete a record' do
    selenium_required!

    find('[data-method=delete]').click
    page.driver.browser.switch_to.alert.accept

    expect(page).not_to have_selector('.record-item-container')
  end

  it "allows modify a record title" do
    selenium_required!
    skip "See https://github.com/HwaYo/parrot/issues/61"

    find('[data-target=#edit-modal]').click
  end
end
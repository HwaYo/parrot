require 'rails_helper'

RSpec.describe 'Account signing in/out process', type: :feature do
  def sign_in!
    visit "/"
    click_link "페이스북으로 시작하기"
  end

  it "signs me in" do
    sign_in!
    expect(page).to have_content("My record list")
  end

  it "signs me out" do
    sign_in!
    find('.dropdown-toggle').click
    click_link "Sign Out"
    expect(page).to have_content("페이스북으로 시작하기")
  end
end
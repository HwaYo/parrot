module AcceptanceHelper
  def selenium?
    [:selenium].include?(Capybara.default_driver);
  end

  def selenium_required!(msg = "")
    skip "selenium required. #{msg}" unless selenium?
  end

  def sign_in!
    visit "/auth/facebook"
  end
end
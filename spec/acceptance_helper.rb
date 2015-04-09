module AcceptanceHelper
  def sign_in!
    visit "/auth/facebook"
  end
end
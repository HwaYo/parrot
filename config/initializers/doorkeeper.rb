Doorkeeper.configure do
  resource_owner_from_credentials do |routes|
    facebook = URI.parse('https://graph.facebook.com/me?access_token=' +
    params[:assertion])
    response = Net::HTTP.get_response(facebook)
    user_data = JSON.parse(response.body)
    User.find_by_uid(user_data['id'])
  end

  access_token_expires_in 1.years
end

Doorkeeper.configuration.token_grant_types << "password"
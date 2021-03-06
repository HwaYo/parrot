Doorkeeper.configure do
  resource_owner_from_credentials do |routes|
    facebook = URI.parse('https://graph.facebook.com/me?access_token=' +
    params[:assertion])
    response = Net::HTTP.get_response(facebook)
    user_data = JSON.parse(response.body)

    registered_user = User.find_by_uid(user_data['id'])
    if registered_user.nil?
      User.create_with_doorkeeper(user_data)
    else
      registered_user
    end
 end

  access_token_expires_in 1.years
end

Doorkeeper.configuration.token_grant_types << "password"
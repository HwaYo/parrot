require 'rails_helper'

RSpec.describe SessionsController, type: :request do
  describe '#create' do
    it 'should create session' do
      user = FactoryGirl.create(:user)
      auth_hash = user.attributes.slice('provider', 'uid')
      auth_hash['info'] = user.attributes.slice('name', 'email', 'image')

      get '/auth/facebook/callback', nil, {
        'omniauth.auth': auth_hash
      }

      expect(User.count).to eq(1)
      expect(session[:user_id]).to eq(user.id)
    end

    it 'should create user if user not found' do
      expect(User.count).to eq(0)

      get '/auth/facebook/callback'
      created_user = User.last

      expect(User.count).to eq(1)
      expect(session[:user_id]).to eq(created_user.id)
    end

    it 'should redirect to records_path' do
      get '/auth/facebook/callback'
      expect(response).to redirect_to(records_path)
    end
  end

  describe '#destroy' do
    before :each do
      get '/auth/facebook/callback'
    end

    it 'should destroy session' do
      get signout_path

      expect(session[:user_id]).to be(nil)
      expect(response).to redirect_to(root_path)
    end
  end
end
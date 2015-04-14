require 'rails_helper'

RSpec.describe HomeController, type: :request do
  describe '#index' do
    it 'should render main page' do
      get root_path
      expect(response).to render_template(:home_application)
    end

    it 'should render records path if signed in' do
      get "/auth/facebook/callback"
      get root_path
      expect(response).to redirect_to(records_path)
    end
  end
end
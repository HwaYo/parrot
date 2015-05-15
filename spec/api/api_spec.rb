require 'rails_helper'

RSpec.describe API do
  before do
    @user ||= FactoryGirl.create(:user)

    Grape::Endpoint.before_each do |endpoint|
      allow(endpoint).to receive(:current_user).and_return(@user)
      allow(endpoint).to receive(:authorize!).and_return(true)
    end
  end

  after do
    Grape::Endpoint.before_each nil
  end

  describe 'GET /api/v1/records/pull' do
    before do
      @record = FactoryGirl.create(:record, user: @user)
    end

    it 'returns records modified after given timestamp' do
      get '/api/v1/records/pull', { last_synced_at: @record.updated_at.to_i - 1 }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(1)
    end

    it 'returns no record modified before given timestamp' do
      get '/api/v1/records/pull', { last_synced_at: @record.updated_at.to_i + 1 }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(0)
    end
  end
end
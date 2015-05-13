require 'doorkeeper/grape/helpers'

class API < Grape::API
  helpers Doorkeeper::Grape::Helpers
  helpers do
    def current_user
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end
  end

  prefix 'api'
  version 'v1', using: :path
  format :json

  before do
    doorkeeper_authorize!
  end

  get 'records' do
    current_user.records.map do |record|
      record.attributes.except("file", "created_at", "updated_at")
    end
  end
end
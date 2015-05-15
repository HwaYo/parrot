require 'doorkeeper/grape/helpers'

module APIEntities
  class Record < Grape::Entity
    expose :uuid, :title, :note, :created_at, :updated_at, :deleted
    expose :file do |record, options|
      if record.file
        record.file.path
      else
        nil
      end
    end
  end
end

class API < Grape::API
  helpers Doorkeeper::Grape::Helpers
  helpers do
    def current_user
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def authorize!
      doorkeeper_authorize!
    end
  end

  prefix 'api'
  version 'v1', using: :path
  format :json

  before do
    authorize!
  end

  resources :records do
    desc "Pull records modified after given timestamp"
    params do
      requires :last_synced_at, type: Integer
    end
    get :pull do
      updated = Record.where('updated_at > ?', Time.at(params[:last_synced_at]))
      present updated, with: APIEntities::Record
    end

    desc "Push records which require synchronization"
    params do
      requires :records, type: Array
    end
    post :push do
      # synchronization logic
    end
  end
end
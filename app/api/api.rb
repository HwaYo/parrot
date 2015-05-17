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

  class Bookmark < Grape::Entity
    expose :uuid, :color, :name, :created_at, :updated_at
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
      updated = current_user.records.where('updated_at > ?', Time.at(params[:last_synced_at]))
      present updated, with: APIEntities::Record
    end

    desc "Push records which require synchronization"
    params do
      requires :records, type: Array
    end
    post :push do
      # synchronization logic
      records = params[:records]

      synced_records = []

      records.each do |record|
        record = record.slice(Record.column_names)
        # Simply overwrite now, but maybe updated_at re-comparison required.
        mapped_record = Record.find_by_uuid(record)
        if mapped_record.nil?
          # Created from local.
          synced_records << current_user.records.create!(record.to_h)
        else
          mapped_record.update_attributes!(record.to_h)
          synced_records << mapped_record
        end
      end

      present synced_records, with: APIEntities::Record
    end
  end

  resources :bookmarks do
    desc "Pull bookmarks modified after given timestamp"
    params do
      requires :last_synced_at, type: Integer
    end
    get :pull do
      updated = current_user.bookmarks.where('updated_at > ?', Time.at(params[:last_synced_at]))
      present updated, with: APIEntities::Bookmark
    end
  end
end
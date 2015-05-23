require 'doorkeeper/grape/helpers'

module APIEntities
  class Record < Grape::Entity
    expose :uuid, :title, :note, :created_at, :updated_at
    expose :file do |record, options|
      if record.file
        record.file.url
      else
        nil
      end
    end
    expose :deleted do |record, options|
      record.deleted?
    end
  end

  class Bookmark < Grape::Entity
    expose :uuid, :color, :name, :created_at, :updated_at
    expose :deleted do |bookmark, options|
      bookmark.deleted?
    end
  end

  class BookmarkHistory < Grape::Entity
    expose :uuid, :start, :end, :created_at, :updated_at
    expose :record_uuid do |history, options|
      history.record.try(:uuid)
    end
    expose :bookmark_uuid do |history, options|
      history.bookmark.try(:uuid)
    end
    expose :deleted do |history, options|
      history.deleted?
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
      updated = current_user.records.from_remote.where('updated_at > ?', Time.at(params[:last_synced_at]))
      present updated, with: APIEntities::Record
    end

    desc "Push records which require synchronization"
    params do
      requires :entities, type: Array
    end
    post :push do
      # synchronization logic
      records = params[:entities] || []

      synced_records = []

      records.each do |record|
        record_params = record.slice(*Record.column_names).except("id", "file")
        # Simply overwrite now, but maybe updated_at re-comparison required.
        mapped_record = Record.find_by_uuid(record_params.uuid)
        if mapped_record.nil?
          # Created from local.
          synced_records << current_user.records.create!(record_params.to_h.compact)
        elsif record.deleted
          mapped_record.destroy
          synced_records << mapped_record
        else
          mapped_record.update_attributes!(record_params.to_h.compact)
          synced_records << mapped_record
        end
      end

      present synced_records, with: APIEntities::Record
    end

    desc "Upload a record file"
    post :file do
      record = Record.find_by_uuid(params[:uuid])
      return if record.nil?

      record.file = params[:file]
      record.save!

      present record, with: APIEntities::Record
    end
  end

  resources :bookmarks do
    desc "Pull bookmarks modified after given timestamp"
    params do
      requires :last_synced_at, type: Integer
    end
    get :pull do
      updated = current_user.bookmarks.with_deleted.where('updated_at > ?', Time.at(params[:last_synced_at]))
      present updated, with: APIEntities::Bookmark
    end

    desc "Push bookmarks which require synchronization"
    params do
      requires :entities, type: Array
    end
    post :push do
      # synchronization logic
      bookmarks = params[:entities] || []

      synced_bookmarks = []

      bookmarks.each do |bookmark|
        bookmark = bookmark.slice(*Bookmark.column_names).except("id")
        # Simply overwrite now, but maybe updated_at re-comparison required.
        mapped_bookmark = Bookmark.find_by_uuid(bookmark.uuid)
        if mapped_bookmark.nil?
          # Created from local.
          synced_bookmarks << current_user.bookmarks.create!(bookmark.to_h.compact)
        elsif bookmark.deleted
          mapped_bookmark.destroy
        else
          mapped_bookmark.update_attributes!(bookmark.to_h.compact)
          synced_bookmarks << mapped_bookmark
        end
      end

      present synced_bookmarks, with: APIEntities::Bookmark
    end
  end

  resources :bookmark_histories do
    desc "Pull bookmark histories modified after given timestamp"
    params do
      requires :last_synced_at, type: Integer
    end
    get :pull do
      bookmarks = current_user.bookmarks
      updated = BookmarkHistory.with_deleted.where(bookmark: bookmarks).where('updated_at > ?', Time.at(params[:last_synced_at]))
      present updated, with: APIEntities::BookmarkHistory
    end

    desc "Push bookmark histories which require synchronization"
    params do
      requires :entities, type: Array
    end
    post :push do
      # synchronization logic
      histories = params[:entities] || []

      synced_histories = []

      histories.each do |history|
        history_params = history.slice(*BookmarkHistory.column_names).except("id", "record_id", "bookmark_id")
        # Simply overwrite now, but maybe updated_at re-comparison required.
        mapped_history = BookmarkHistory.find_by_uuid(history_params.uuid)
        if mapped_history.nil?
          # Created from local.
          new_history = BookmarkHistory.new(history_params.to_h.compact)
          new_history.bookmark = Bookmark.find_by_uuid(history.bookmark_uuid)
          new_history.record = Record.find_by_uuid(history.record_uuid)
          new_history.save!

          synced_histories << new_history
        elsif history.deleted
          mapped_history.destroy
        else
          mapped_history.assign_attributes(history_params.to_h.compact)
          mapped_history.bookmark = Bookmark.find_by_uuid(history.bookmark_uuid)
          mapped_history.record = Record.find_by_uuid(history.record_uuid)
          mapped_history.save!

          synced_histories << mapped_history
        end
      end

      present synced_histories, with: APIEntities::BookmarkHistory
    end
  end
end
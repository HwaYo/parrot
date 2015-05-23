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
      @url = '/api/v1/records/pull'.freeze
      @record = FactoryGirl.create(:record, user: @user)
    end

    it 'validates request parameters' do
      get @url, { last_synced_at: "Hello" }
      expect(response.status).to eq(400)
    end

    it 'returns records modified after given timestamp' do
      get @url, { last_synced_at: @record.updated_at.to_i - 1 }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(1)
    end

    it 'returns no record modified before given timestamp' do
      get @url, { last_synced_at: @record.updated_at.to_i + 1 }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(0)
    end

    it 'returns records create from server' do
      local_record = FactoryGirl.create(:record, file: nil)
      get @url, { last_synced_at: local_record.updated_at.to_i - 1 }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(1)
    end

    it 'returns even records deleted from server' do
      deleted_record = FactoryGirl.create(:record, user: @user)
      deleted_record.destroy

      get @url, { last_synced_at: @record.updated_at.to_i - 1 }
      expect(response.status).to eq(200)

      records = JSON.parse(response.body)
      expect(records.count).to eq(2)
      expect(records.last["deleted"]).to eq(true)
    end
  end

  describe 'POST /api/v1/records/push' do
    before do
      @url = '/api/v1/records/push'.freeze
      @record = FactoryGirl.create(:record, user: @user)
    end

    it 'validates request parameters' do
      post @url, entities: 'Hello'
      expect(response.status).to eq(400)

      post @url, entities: [@record.attributes]
      expect(response.status).to eq(201)
    end

    it 'creates records which create at local' do
      local_record = @record.dup
      local_record.uuid = SecureRandom.uuid
      local_record.title = "CreatedTitle"

      post @url, entities: [local_record.attributes]

      clean_records = JSON.parse(response.body)
      expect(clean_records.count).to eq(1)

      clean_record = clean_records.first
      created_record = Record.find_by_uuid(clean_record["uuid"])
      expect(created_record).not_to eq(nil)
      expect(created_record.title).to eq("CreatedTitle")
    end

    it 'updates records updated at local' do
      local_record = @record.dup
      local_record.title = "ModifiedTitle"

      post @url, entities: [local_record.attributes]

      clean_records = JSON.parse(response.body)
      expect(clean_records.count).to eq(1)

      clean_record = clean_records.first
      expect(clean_record["title"]).to eq("ModifiedTitle")

      updated_record = Record.find_by_uuid(clean_record["uuid"])
      expect(updated_record.title).to eq("ModifiedTitle")
    end
  end

  describe 'GET /api/v1/records/:uuid' do
    before do
      @record = FactoryGirl.create(:record, user: @user)
    end

    it 'returns a record entity' do
      get '/api/v1/records/%s' % @record.uuid
      expect(response.status).to eq(200)
      expect(response.body).to eq(APIEntities::Record.represent(@record).to_json)
    end
  end

  describe 'GET /api/v1/bookmarks/pull' do
    before do
      @url = '/api/v1/bookmarks/pull'.freeze
      @bookmark = FactoryGirl.create(:bookmark, user: @user)
    end

    it 'validates request parameters' do
      get @url, { last_synced_at: "Hello" }
      expect(response.status).to eq(400)
    end

    it 'returns bookmarks modified after given timestamp' do
      get @url, { last_synced_at: @bookmark.updated_at.to_i - 1 }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(1)
    end

    it 'returns no bookmark modified before given timestamp' do
      get @url, { last_synced_at: @bookmark.updated_at.to_i + 1 }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(0)
    end

    it 'returns bookmarks create from server' do
      get @url, { last_synced_at: @bookmark.updated_at.to_i - 1 }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(1)
    end

    it 'returns even bookmarks deleted from server' do
      deleted_bookmark = FactoryGirl.create(:bookmark, user: @user)
      deleted_bookmark.destroy

      get @url, { last_synced_at: @bookmark.updated_at.to_i - 1 }
      expect(response.status).to eq(200)

      bookmarks = JSON.parse(response.body)
      expect(bookmarks.count).to eq(2)
      expect(bookmarks.last["deleted"]).to eq(true)
    end
  end

  describe 'POST /api/v1/bookmarks/push' do
    before do
      @url = '/api/v1/bookmarks/push'.freeze
      @bookmark = FactoryGirl.create(:bookmark, user: @user)
    end

    it 'validates request parameters' do
      post @url, entities: 'Hello'
      expect(response.status).to eq(400)

      post @url, entities: [@bookmark.attributes]
      expect(response.status).to eq(201)
    end

    it 'creates bookmarks which create at local' do
      local_bookmark = @bookmark.dup
      local_bookmark.uuid = SecureRandom.uuid
      local_bookmark.name = "CreatedName"

      post @url, entities: [local_bookmark.attributes]

      clean_bookmarks = JSON.parse(response.body)
      expect(clean_bookmarks.count).to eq(1)

      clean_bookmark = clean_bookmarks.first
      created_bookmark = Bookmark.find_by_uuid(clean_bookmark["uuid"])
      expect(created_bookmark).not_to eq(nil)
      expect(created_bookmark.name).to eq("CreatedName")
    end

    it 'updates bookmarks updated at local' do
      local_bookmark = @bookmark.dup
      local_bookmark.name = "ModifiedName"

      post @url, entities: [local_bookmark.attributes]

      clean_bookmarks = JSON.parse(response.body)
      expect(clean_bookmarks.count).to eq(1)

      clean_bookmark = clean_bookmarks.first
      expect(clean_bookmark["name"]).to eq("ModifiedName")

      updated_bookmark = Bookmark.find_by_uuid(clean_bookmark["uuid"])
      expect(updated_bookmark.name).to eq("ModifiedName")
    end
  end

  describe 'GET /api/v1/bookmark_histories/pull' do
    before do
      @url = '/api/v1/bookmark_histories/pull'.freeze
      @record = FactoryGirl.create(:record, user: @user)
      @bookmark = FactoryGirl.create(:bookmark, user: @user)
      @history = FactoryGirl.create(:bookmark_history, record: @record, bookmark: @bookmark)
    end

    it 'validates request parameters' do
      get @url, { last_synced_at: "Hello" }
      expect(response.status).to eq(400)
    end

    it 'returns histories modified after given timestamp' do
      get @url, { last_synced_at: @history.updated_at.to_i - 1 }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(1)
    end

    it 'returns no history modified before given timestamp' do
      get @url, { last_synced_at: @history.updated_at.to_i + 1 }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(0)
    end

    it 'returns histories create from server' do
      get @url, { last_synced_at: @history.updated_at.to_i - 1 }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(1)
    end

    it 'returns even histories deleted from server' do
      deleted_history = FactoryGirl.create(:bookmark_history, record: @record, bookmark: @bookmark)
      deleted_history.destroy

      get @url, { last_synced_at: @history.updated_at.to_i - 1 }
      expect(response.status).to eq(200)

      histories = JSON.parse(response.body)
      expect(histories.count).to eq(2)
      expect(histories.last["deleted"]).to eq(true)
    end

    it 'returns with record, bookmark uuid' do
      get @url, { last_synced_at: @history.updated_at.to_i - 1 }
      expect(response.status).to eq(200)

      history = JSON.parse(response.body).first
      expect(history["record_uuid"]).to eq(@history.record.uuid)
      expect(history["bookmark_uuid"]).to eq(@history.bookmark.uuid)
    end
  end

  describe 'POST /api/v1/bookmark_histories/push' do
    before do
      @url = '/api/v1/bookmark_histories/push'.freeze
      @record = FactoryGirl.create(:record, user: @user)
      @bookmark = FactoryGirl.create(:bookmark, user: @user)
      @history = FactoryGirl.create(:bookmark_history, record: @record, bookmark: @bookmark)
    end

    it 'validates request parameters' do
      post @url, entities: 'Hello'
      expect(response.status).to eq(400)

      post @url, entities: [@history.attributes]
      expect(response.status).to eq(201)
    end

    it 'creates histories which create at local' do
      local_history = @history.dup
      local_history.uuid = SecureRandom.uuid
      local_history.start = 10

      post @url, entities: [local_history.attributes]

      clean_histories = JSON.parse(response.body)
      expect(clean_histories.count).to eq(1)

      clean_bookmark = clean_histories.first
      created_bookmark = BookmarkHistory.find_by_uuid(clean_bookmark["uuid"])
      expect(created_bookmark).not_to eq(nil)
      expect(created_bookmark.start).to eq(10)
    end

    it 'updates histories updated at local' do
      local_history = @history.dup
      local_history.start = 10

      post @url, entities: [local_history.attributes]

      clean_histories = JSON.parse(response.body)
      expect(clean_histories.count).to eq(1)

      clean_history = clean_histories.first
      expect(clean_history["start"]).to eq(10)

      updated_history = BookmarkHistory.find_by_uuid(clean_history["uuid"])
      expect(updated_history.start).to eq(10)
    end

    it 'associates histories with record, bookmark' do
      local_history = @history.dup
      local_history.uuid = SecureRandom.uuid
      local_history.start = 2

      params = local_history.attributes.merge({
        record_uuid: local_history.record.uuid,
        bookmark_uuid: local_history.bookmark.uuid
      })

      post @url, entities: [params]
      clean_histories = JSON.parse(response.body)
      expect(clean_histories.count).to eq(1)

      clean_history = clean_histories.first
      created_history = BookmarkHistory.find_by_uuid(clean_history["uuid"])
      expect(created_history.record).to eq(@record)
      expect(created_history.bookmark).to eq(@bookmark)
      expect(@bookmark.bookmark_histories.count).to eq(2)
    end
  end
end
require 'rails_helper'

RSpec.describe RecordsController, type: :request do
  before :each do
    get '/auth/facebook/callback'
    @user = User.first
    @record = FactoryGirl.create(:record, user: @user)
  end

  describe '#index' do
    it 'should render only record which belongs to user' do
      get records_path
      expect(response.body).to include(@record.title)
    end
  end

  describe '#new' do
    it 'shows new record page' do
      get new_record_path
      expect(response.status).to eq(200)
    end
  end

  describe '#edit' do
    it 'shows edit record page' do
      get "/records/#{@record.id}/edit"
      expect(response.body).to include('test record')
    end
  end

  describe '#update' do
    it 'updates record' do
      attributes = @record.attributes
      attributes['title'] = 'updated title'
      put record_path(@record), { record: attributes }
      expect(response).to redirect_to(records_path)
    end

    it 'should not update record if not passing validation' do
      attributes = @record.attributes
      attributes['title'] = ''
      put record_path(@record), { record: attributes }

      expect(response.status).to eq(500)
      expect(response).to render_template(partial: '_edit_modal')
    end
  end

  describe '#create' do
    it 'creates a record' do
      post records_path, {
        record: @record.attributes.merge({
          file: Rack::Test::UploadedFile.new(Rails.root.join('spec/files/blob.wav'), "audio/wav")
        })
      }
      created = Record.last

      expect(response.body).to eq(JSON.generate({
        href: record_path(created)
      }))
    end
  end

  describe '#show' do
    it 'should render show page' do
      get record_path(@record)
      expect(response).to render_template(:show)
    end
  end

  describe '#bookmark_json' do
    it 'should return bookmarks of record' do
      get bookmark_json_record_path(@record)
      expect(response.body).to eq(%q([{"start":0.5,"end":1.5,"data":1}]))
    end
  end

  describe '#destroy' do
    # Soft delete
    it 'should destroy record' do
      delete record_path(@record)
      deleted_record = Record.find(@record.id)
      expect(deleted_record.deleted).to eq(true)
    end
  end
end
require 'rails_helper'

RSpec.describe BookmarksController, type: :request do
  before :each do
    get '/auth/facebook/callback'
    @user = User.first
    @bookmark = FactoryGirl.create(:bookmark, user: @user)
  end

  describe '#index' do
    it 'should render index page' do
      get bookmarks_path
      expect(response).to render_template(:index)
    end
  end

  # name, color presence validation required + error handling
  describe '#create' do
    it 'should create a new bookmark' do
      attributes = @bookmark.attributes.slice('name', 'color')
      post bookmarks_path, { bookmark: @bookmark.attributes }

      created = Bookmark.last
      expect(created).to have_attributes(attributes)
      expect(response).to redirect_to(bookmarks_path)
    end
  end

  describe '#update' do
    it 'should update bookmark' do
      attributes = @bookmark.attributes.slice('name', 'color')
      attributes['name'] += 'Hello'
      put bookmark_path(@bookmark), { bookmark: attributes }

      @bookmark.reload
      expect(@bookmark).to have_attributes(attributes)
      expect(response).to redirect_to(bookmarks_path)
    end

    it 'should render edit when validation error occurred' do
      attributes = @bookmark.attributes.slice('name', 'color')
      attributes['name'] = ''
      put bookmark_path(@bookmark), { bookmark: attributes }

      expect(response.status).to eq(500)
      expect(response).to render_template(partial: '_edit')
    end
  end

  describe '#edit' do
    it 'should render edit partial' do
      get edit_bookmark_path(@bookmark)
      expect(response).to render_template(partial: '_edit')
    end
  end

  describe '#destroy' do
    it 'should destroy bookmark' do
      delete bookmark_path(@bookmark)

      destroyed_bookmark = Bookmark.find_by(id: @bookmark.id)
      expect(destroyed_bookmark).to be(nil)
      expect(response).to redirect_to(bookmarks_path)
    end
  end
end
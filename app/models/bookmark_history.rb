class BookmarkHistory < ActiveRecord::Base
  include SyncableModel

  belongs_to :bookmark, dependent: :destroy
  belongs_to :record, dependent: :destroy
end

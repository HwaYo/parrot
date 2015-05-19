class BookmarkHistory < ActiveRecord::Base
  include SyncableModel

  belongs_to :bookmark
  belongs_to :record
end

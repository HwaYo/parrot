class AddUuidToEntities < ActiveRecord::Migration
  class Record < ActiveRecord::Base
  end

  class Bookmark < ActiveRecord::Base
  end

  def self.up
    add_column :records, :uuid, :string

    Record.transaction do
      Record.all.each do |record|
        record.uuid = SecureRandom.uuid
        record.save!
      end
    end

    add_column :bookmarks, :uuid, :string

    Bookmark.transaction do
      Bookmark.all.each do |bookmark|
        bookmark.uuid = SecureRandom.uuid
        bookmark.save!
      end
    end
  end

  def self.down
    remove_column :records, :uuid
    remove_column :bookmarks, :uuid
  end
end

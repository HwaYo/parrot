class CreateBookmarkHistories < ActiveRecord::Migration
  def self.up
    create_table :bookmark_histories do |t|
      t.float :start
      t.float :end
      t.belongs_to :record
      t.belongs_to :bookmark
      t.string :uuid
      t.timestamps null: false
    end

    BookmarkHistory.reset_column_information

    Record.all.each do |record|
      next if record.bookmark.nil?
      bookmark_histories = JSON.parse(record.bookmark)

      bookmark_histories.each do |history|
        bookmark = Bookmark.find_by_name(history["name"])
        next if bookmark.nil?

        bookmark_history = record.bookmark_histories.build(history.slice(*BookmarkHistory.column_names))
        bookmark_history.bookmark = bookmark
        bookmark_history.save!
      end
    end

    remove_column :records, :bookmark
  end

  def self.down
    drop_table :bookmark_histories
    add_column :records, :bookmark, :text
  end
end

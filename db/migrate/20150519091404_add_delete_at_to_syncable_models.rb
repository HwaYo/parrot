class AddDeleteAtToSyncableModels < ActiveRecord::Migration
  def change
    remove_column :records, :deleted, :boolean

    add_column :records, :deleted_at, :datetime
    add_index :records, :deleted_at

    add_column :bookmarks, :deleted_at, :datetime
    add_index :bookmarks, :deleted_at

    add_column :bookmark_histories, :deleted_at, :datetime
    add_index :bookmark_histories, :deleted_at
  end
end

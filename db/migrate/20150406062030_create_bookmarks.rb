class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.string :color
      t.string :name
      t.belongs_to :user, index: true
      t.timestamps null: false
    end
  end
end

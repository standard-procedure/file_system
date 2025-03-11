class CreateFileSystemComments < ActiveRecord::Migration[8.0]
  def change
    create_table :file_system_comments do |t|
      t.belongs_to :item_revision, foreign_key: {to_table: "file_system_item_revisions"}
      t.belongs_to :creator, polymorphic: true, index: true
      t.timestamps
    end
  end
end
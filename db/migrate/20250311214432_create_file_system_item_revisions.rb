class CreateFileSystemItemRevisions < ActiveRecord::Migration[8.0]
  def change
    create_table :file_system_item_revisions do |t|
      t.belongs_to :item, foreign_key: {to_table: "file_system_items"}
      t.belongs_to :creator, polymorphic: true, index: true
      t.belongs_to :contents, polymorphic: true, index: true
      t.string :name, default: "", null: false
      t.integer :number, null: false
      t.text :metadata
      t.timestamps
    end
  end
end

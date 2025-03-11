class CreateFileSystemFolders < ActiveRecord::Migration[8.0]
  def change
    create_table :file_system_folders do |t|
      t.belongs_to :volume, foreign_key: {to_table: "file_system_volumes"}
      t.belongs_to :parent, foreign_key: {to_table: "file_system_folders"}
      t.string :name, default: "", null: false
      t.integer :status, default: 0, null: false
      t.timestamps
    end

    add_index :file_system_folders, [:volume_id, :parent_id, :status, :name], unique: true
  end
end

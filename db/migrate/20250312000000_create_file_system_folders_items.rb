class CreateFileSystemFoldersItems < ActiveRecord::Migration[8.0]
  def change
    create_join_table :file_system_folders, :file_system_items, table_name: :file_system_folders_items do |t|
      t.index [:file_system_folder_id, :file_system_item_id], unique: true, name: "index_folders_items_on_folder_id_and_item_id"
      t.index [:file_system_item_id, :file_system_folder_id], name: "index_folders_items_on_item_id_and_folder_id"
      t.timestamps
    end

    add_foreign_key :file_system_folders_items, :file_system_folders, column: :file_system_folder_id
    add_foreign_key :file_system_folders_items, :file_system_items, column: :file_system_item_id
  end
end

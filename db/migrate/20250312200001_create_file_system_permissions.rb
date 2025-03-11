class CreateFileSystemPermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :file_system_permissions do |t|
      t.belongs_to :folder, foreign_key: {to_table: "file_system_folders"}
      t.belongs_to :subject, polymorphic: true, index: true
      t.timestamps
    end
    
    add_index :file_system_permissions, [:folder_id, :subject_id, :subject_type], unique: true, name: 'index_fs_permissions_on_folder_and_subject'
  end
end
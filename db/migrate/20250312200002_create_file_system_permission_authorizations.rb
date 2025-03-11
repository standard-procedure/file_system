class CreateFileSystemPermissionAuthorizations < ActiveRecord::Migration[8.0]
  def change
    create_table :file_system_permission_authorizations do |t|
      t.belongs_to :permission, foreign_key: {to_table: "file_system_permissions"}
      t.belongs_to :authorization, foreign_key: {to_table: "file_system_authorizations"}
      t.timestamps
    end
    
    add_index :file_system_permission_authorizations, 
              [:permission_id, :authorization_id], 
              unique: true, 
              name: 'index_fs_permission_auths_on_permission_and_auth'
  end
end
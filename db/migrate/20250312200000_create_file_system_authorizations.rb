class CreateFileSystemAuthorizations < ActiveRecord::Migration[8.0]
  def change
    create_table :file_system_authorizations do |t|
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :file_system_authorizations, :name, unique: true
  end
end

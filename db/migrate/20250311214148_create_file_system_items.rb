class CreateFileSystemItems < ActiveRecord::Migration[8.0]
  def change
    create_table :file_system_items do |t|
      t.belongs_to :volume, foreign_key: {to_table: "file_system_volumes"}
      t.integer :status, default: 0, null: false
      t.timestamps
    end
  end
end

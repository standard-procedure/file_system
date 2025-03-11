class CreateFileSystemVolumes < ActiveRecord::Migration[8.0]
  def change
    create_table :file_system_volumes do |t|
      t.string :name, default: "", null: false
      t.integer :status, default: 0, null: false
      t.timestamps
    end
    add_index :file_system_volumes, :name, unique: true
  end
end
